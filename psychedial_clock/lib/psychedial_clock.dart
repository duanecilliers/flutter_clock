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
		_controller = AnimationController(
			vsync: this,
			duration: Duration(milliseconds: 2000)
		)
		..addStatusListener((status) {
			if (status == AnimationStatus.completed) {
				_controller.reverse();
			} else if (status == AnimationStatus.dismissed) {
				_controller.forward();
			}
		})..forward();
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

	@override
	Widget build(BuildContext context) {
		final date = DateTime.now();
		final time = DateFormat.Hms().format(date);

		final gradients = [
      this._getGradient([colors[1], colors[0]]),
      this._getGradient([colors[2], colors[1]]),
      this._getGradient([colors[3], colors[2]]),
      this._getGradient([colors[4], colors[3]]),
      this._getGradient([colors[0], colors[4]])
    ];

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
							begin: gradients[1],
							end: gradients[0],
							controller: _controller,
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 0.8,
								angleRadians: _hourIn12HourFormat * radiansPerHour,
							),
						),
						GradientAnimation(
							begin: gradients[2],
							end: gradients[1],
							controller: _controller,
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 0.9,
								angleRadians: _now.minute * radiansPerTick,
							),
						),
						GradientAnimation(
							begin: gradients[3],
							end: gradients[2],
							controller: _controller,
							childWidget: animateDrawnHand(
								thickness: 14,
								size: 1,
								angleRadians: _now.second * radiansPerTick,
							),
						),
					],
				),
			),
		);
	}
}
