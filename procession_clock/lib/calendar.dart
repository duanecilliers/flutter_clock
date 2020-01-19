import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return Container(
      child: CustomPaint(
          painter: _PaintYear(
        dateUtil: DateUtil(),
        year: date.year,
        month: date.month,
        day: date.day,
        color: color,
      )),
    );
  }
}

class _PaintYear extends CustomPainter {
  _PaintYear({
    @required this.dateUtil,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.color,
  });

  final DateUtil dateUtil;
  final int year;
  final int month;
  final int day;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double dayLineHeight = 80;
    final double verticalSpacing = 24;
    final double weekPadding = 24;

    double yOffset = 0;
    double xOffset = 0;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    final int daysInYear = dateUtil.leapYear(year) ? 366 : 365;
    final int daysPastInYear = dateUtil.daysPastInYear(month, day, year);

    for (double i = 0; i < daysInYear; i++) {
      yOffset++;

      if (i < daysPastInYear) {
        linePaint.color = color.withAlpha(60);
      } else {
        linePaint.color = color.withAlpha(255);
      }

      if (isInteger(i / 7)) {
        xOffset = xOffset + weekPadding;
        yOffset = 0;
      }

      double nextXOffset = xOffset + weekPadding;
      double nextYOffset = dayLineHeight * yOffset;
      double topPoint = nextYOffset + verticalSpacing;
      Offset topOffset = Offset(nextXOffset, topPoint);
      double bottomPoint = nextYOffset + dayLineHeight;
      Offset bottomOffset = Offset(nextXOffset, bottomPoint);

      canvas.drawLine(topOffset, bottomOffset, linePaint);
    }
  }

  @override
  bool shouldRepaint(_PaintYear oldDelegate) {
    return oldDelegate.year != year ||
        oldDelegate.month != month ||
        oldDelegate.day != day ||
        oldDelegate.color != color;
  }
}
