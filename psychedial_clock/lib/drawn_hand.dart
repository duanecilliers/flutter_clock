// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand.dart';

/// A clock hand that is drawn with [CustomPainter]
///
/// The hand's length scales based on the clock's size.
/// This hand is used to build the second and minute hands, and demonstrates
/// building a custom hand.
class DrawnHand extends Hand {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const DrawnHand({
    @required Gradient gradient,
    @required this.thickness,
    @required double size,
    @required double angleRadians,
  })  : assert(gradient != null),
        assert(thickness != null),
        assert(size != null),
        assert(angleRadians != null),
        super(
          gradient: gradient,
          size: size,
          angleRadians: angleRadians,
        );

  /// How thick the hand should be drawn, in logical pixels.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HandPainter(
            handSize: size,
            lineWidth: thickness,
            angleRadians: angleRadians,
            gradient: gradient,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _HandPainter extends CustomPainter {
  _HandPainter({
    @required this.handSize,
    @required this.lineWidth,
    @required this.angleRadians,
    @required this.gradient,
  })  : assert(handSize != null),
        assert(lineWidth != null),
        assert(angleRadians != null),
        assert(gradient != null),
        assert(handSize >= 0.0),
        assert(handSize <= 1.0);

  double handSize;
  double lineWidth;
  double angleRadians;
  Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
		final angle = math.pi / math.pi * angleRadians;
    final length = size.shortestSide * 0.6 * handSize;
		final drawLineWidth = size.shortestSide < 500 ? lineWidth / 1.4 : lineWidth;
		final circleSize = (length * 2 / 1.4);
		final rect = new Rect.fromLTWH(0, 0, circleSize, circleSize);

		final handleTrackPaint = Paint()
			..shader = gradient.createShader(rect)
			..color = Color(0xFFFFFFFF)
			..style = PaintingStyle.stroke
			..strokeWidth = drawLineWidth
			..strokeCap = StrokeCap.round;

		canvas.drawCircle(center, length / 1.4, handleTrackPaint);

		final handPaint = Paint()
			..color = Color(0xFF000000)
			..style = PaintingStyle.stroke
			..strokeWidth = drawLineWidth - 6
			..strokeCap = StrokeCap.round;

		canvas.drawArc(
        Rect.fromCenter(center: center, width: circleSize, height: circleSize),
        -math.pi / 2,
        angle,
        false,
        handPaint
    );
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) {
    return oldDelegate.handSize != handSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.angleRadians != angleRadians ||
        oldDelegate.gradient != gradient;
  }
}
