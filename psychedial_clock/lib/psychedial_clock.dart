import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:psychedial_clock/gradient_animation.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

enum clockHands {
	hour,
	minute,
	second
}

class PsychedialClock extends StatefulWidget {
	const PsychedialClock(this.model);

	final ClockModel model;

	@override
	_PsychedialClockState createState() => _PsychedialClockState();
}

class _PsychedialClockState extends State<PsychedialClock> with SingleTickerProviderStateMixin<PsychedialClock>   {
	var _now = DateTime.now();
	var _hourIn12HourFormat = TimeOfDay.now().hourOfPeriod;
	Timer _timer;
	AnimationController _controller;
	List<Gradient> gradients;
	LinearGradient hourGradient;
	LinearGradient minutesGradient;

	final colors = <Color>[
		Color(0xFFFFE862),
		Color(0xFFFF6262),
		Color(0xFFFF62EB),
		Color(0xFF62A8FF),
		Color(0xFF62FFB5)
	];

	@override
	void initState() {
		widget.model.addListener(_updateModel);
		_updateTime();
		_updateModel();

		gradients = [
      this._getGradient([colors[1], colors[0]]),
      this._getGradient([colors[2], colors[1]]),
      this._getGradient([colors[3], colors[2]]),
      this._getGradient([colors[4], colors[3]]),
      this._getGradient([colors[0], colors[3]]),
    ];
		hourGradient = gradients[0];
		minutesGradient = gradients[1];

		_controller = AnimationController(
			vsync: this,
			duration: Duration(seconds: 60)
		)..repeat();
		super.initState();
	}

	@override
	void didUpdateWidget(PsychedialClock oldWidget) {
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
		/// @todo update model with temp, location etc
	}

	void _updateTime() {
		setState(() {
			_now = DateTime.now();
			_hourIn12HourFormat = TimeOfDay.now().hourOfPeriod;
			_timer = Timer(
				Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
				_updateTime
			);
		});
	}

	LinearGradient _getGradient(List<Color> colors) {
		return new LinearGradient(
			begin: Alignment.centerLeft,
			end: Alignment.centerRight,
			colors: colors
		);
	}


	animateDrawnHand({
		double thickness, double size, angleRadians
	}) => (gradient) => DrawnHand(
		gradient: gradient,
		thickness: thickness,
		size: size,
		angleRadians: angleRadians,
	);

	List<Gradient> getHourGradients () =>
		gradients;

	List<Gradient> getMinuteGradients () =>
		new List.from(gradients)
			..removeAt(0)
			..add(gradients[gradients.length - 1]);

	List<Gradient> getSecondsGradients () {
		var minuteGradients = getMinuteGradients();
		return new List.from(minuteGradients)
			..removeAt(0)
			..add(minuteGradients[gradients.length - 1]);
	}

	Function handleAnimationChange (hand) {
		return (value) {
			if (hand == clockHands.hour) {
				hourGradient = value;
			} else if (hand == clockHands.minute) {
				minutesGradient = value;
			}
		};
	}

	@override
	Widget build(BuildContext context) {
		final date = DateTime.now();
    final time = DateFormat.Hms().format(date);
		final hour = date.hour < 10 ? '0' + _now.hour.toString() : _now.hour.toString();
		final minute = date.minute < 10 ? '0' + _now.minute.toString() : _now.minute.toString();
		final month = new DateFormat.MMM().format(date);
		final dayName = new DateFormat.E().format(date);
		final dayInMonth = new DateFormat.d().format(date);

		// Digital clock
		final size = MediaQuery.of(context).size;
		final fontSize = size.shortestSide / 24;
		final timeStyle = TextStyle(
      fontFamily: 'PressStart2P',
			fontSize: fontSize,
			height: 0.9
    );
		final timeRect = Rect.fromLTWH(0.0, 0.0, 200.0, 70.0);
		final hourStyle = timeStyle.copyWith(
			foreground: Paint()..shader = hourGradient.createShader(timeRect)
		);
		final minutesStyle = timeStyle.copyWith(
			foreground: Paint()..shader = minutesGradient.createShader(timeRect)
		);
		final dateStyle = TextStyle(
			fontSize: fontSize / 2,
			textBaseline: TextBaseline.alphabetic,
			height: 1
		);

		return Semantics.fromProperties(
			properties: SemanticsProperties(
				label: 'Psychedial clock with time $time',
				value: time,
			),
			child: Container(
				decoration: BoxDecoration(
					color: Colors.black,
				),
				child: Stack(
					children: [
						GradientAnimation(
							gradients: getHourGradients(),
							controller: _controller,
							onAnimationChange: handleAnimationChange(clockHands.hour),
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 0.8,
								angleRadians: _hourIn12HourFormat * radiansPerHour,
							),
						),
						GradientAnimation(
							gradients: getMinuteGradients(),
							controller: _controller,
							onAnimationChange: handleAnimationChange(clockHands.minute),
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 0.9,
								angleRadians: _now.minute * radiansPerTick,
							),
						),
						GradientAnimation(
							gradients: getSecondsGradients(),
							controller: _controller,
							onAnimationChange: handleAnimationChange(clockHands.second),
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 1,
								angleRadians: _now.second * radiansPerTick,
							),
						),
						Center(
							child: DefaultTextStyle(
								style: timeStyle,
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										Text(month.toUpperCase(), style: dateStyle.copyWith(letterSpacing: 5)),
										Text(hour, style: hourStyle.copyWith(height: 1)),
										Text(minute.toString(), style: minutesStyle),
										Text(dayName.toUpperCase() + ' ' + dayInMonth.toUpperCase(), style: dateStyle),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
