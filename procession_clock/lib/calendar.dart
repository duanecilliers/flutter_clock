import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({@required this.color, @required this.size});
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    print('size $size');
    final date = DateTime.now();
    return Container(
      child: CustomPaint(
          painter: _PaintYear(
        dateUtil: DateUtil(),
        year: date.year,
        month: date.month,
        day: date.day,
        color: color,
        canvasSize: size,
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
    @required this.canvasSize,
  });

  final DateUtil dateUtil;
  final int year;
  final int month;
  final int day;
  final Color color;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    final double lineCount = 371;
    final int daysInYear = dateUtil.leapYear(year) ? 366 : 365;
    final int daysPastInYear = dateUtil.daysPastInYear(month, day, year);
    final double strokeWidth = 2;
    final double verticalPadding = 16;
    final double columnCount = daysInYear / 7;
    final double horizontalPadding = (canvasSize.width / columnCount) - 1;
    final double dayLineHeight = (canvasSize.height / 7) - verticalPadding;

    double yOffset = 0;
    double xOffset = 0;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    for (double i = 0; i < lineCount; i++) {
      yOffset++;

      if (i < daysPastInYear) {
        linePaint.color = color.withAlpha(60);
      } else if (i > daysInYear) {
        linePaint.color = color.withAlpha(30);
      } else {
        linePaint.color = color.withAlpha(255);
      }

      if (isInteger(i / 7)) {
        xOffset = xOffset + horizontalPadding;
        yOffset = 0;
      }

      double nextXOffset = xOffset;
      double nextYOffset = dayLineHeight * yOffset;
      double topPoint = nextYOffset + verticalPadding;
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
