// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'draw_circular_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  // var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      // _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF31224A)
          );

		final backgroundGradient = Theme.of(context).brightness == Brightness.light
			? RadialGradient(colors: <Color>[
				Color(0xFF46C4FF),
				Color(0xFF1AA1E4),
			])
			: RadialGradient(colors: <Color>[
				Color(0xFF042E66),
				Color(0xFF2E0467),
				Color(0xFF31224A),
			]);

		final backgroundImage = Theme.of(context).brightness == Brightness.light
			? AssetImage('assets/sun.png')
			: AssetImage('assets/moon.png');

		final date = DateTime.now();
    final time = DateFormat.Hms().format(date);
		final hour = date.hour < 10 ? '0' + _now.hour.toString() : _now.hour.toString();
		final minute = date.minute < 10 ? '0' + _now.minute.toString() : _now.minute.toString();
		final month = new DateFormat.MMM().format(date);
		final dayName = new DateFormat.E().format(date);
		final dayInMonth = new DateFormat.d().format(date);
		// final year = new DateFormat.y().format(date);

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
					/** @todo condition will be graphical */
          // Text(_condition),
          Text(_location),
        ],
      ),
    );

		// Digital clock
		final size = MediaQuery.of(context).size;
		final fontSize = size.shortestSide / 24;
		final timeStyle = TextStyle(
      color: Color(0xFF222222),
      fontFamily: 'PressStart2P',
			fontSize: fontSize,
			height: 0.9
    );
		final dateStyle = TextStyle(
			fontSize: fontSize / 2,
			textBaseline: TextBaseline.alphabetic,
			height: 1
		);

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        decoration: BoxDecoration(
					gradient: backgroundGradient,
					image: DecorationImage(
							image: Theme.of(context).brightness == Brightness.light
								? AssetImage('assets/stars-day.png')
								: AssetImage('assets/stars-night.png')
						),
				),
        child: Container(
					decoration: BoxDecoration(
						image: DecorationImage(
							image: backgroundImage,
							fit: BoxFit.contain
						),
					),
					child: Stack(
						children: [
							// Example of a hand drawn with [CustomPainter].
							DrawnHand(
								color: Colors.black87,
								thickness: 3,
								size: 0.82,
								angleRadians: _now.second * radiansPerTick,
							),
							DrawnHand(
								color: customTheme.highlightColor,
								thickness: 6,
								size: 0.76,
								angleRadians: _now.minute * radiansPerTick,
							),
							DrawnHand(
								color: customTheme.highlightColor,
								thickness: 9,
								size: 0.69,
								angleRadians: _now.hour * radiansPerHour,
							),
							Center(
								child: DefaultTextStyle(
									style: timeStyle,
									child: Column(
										mainAxisAlignment: MainAxisAlignment.center,
										children: <Widget>[
											Text(month.toUpperCase(), style: dateStyle.copyWith(letterSpacing: 5)),
											Text(hour, style: timeStyle.copyWith(height: 1)),
											Text(minute.toString()),
											Text(dayName.toUpperCase() + ' ' + dayInMonth.toUpperCase(), style: dateStyle),
										],
									),
								),
							),
							Positioned(
								left: 0,
								bottom: 0,
								child: Padding(
									padding: const EdgeInsets.all(8),
									child: weatherInfo,
								),
							),
						],
					),
				)
      ),
    );
  }
}
