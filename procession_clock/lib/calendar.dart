import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    @required this.color,
    @required this.size,
    @required this.dateUtil,
  });
  final Color color;
  final Size size;
  final DateUtil dateUtil;

  List<String> days() {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
  }

  int initialDayOffset(date) {
    final firstDayOfYear =
        dateUtil.day(dateUtil.totalLengthOfDays(1, 1, date.year));
    return days().indexOf(firstDayOfYear);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final fontSize = size.height / 30;

    final double verticalPadding = 16;
    final double dayHeight = (size.height / 7) - verticalPadding;

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(children: <Widget>[
            DayLabels(
              fontSize: fontSize,
              dayHeight: dayHeight,
              currentDay: dateUtil.dayOfWeek,
              color: color,
              days: days(),
            ),
          ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: CustomPaint(
                  painter: _PaintYear(
                    dateUtil: dateUtil,
                    year: date.year,
                    month: date.month,
                    day: date.day,
                    dayOffset: initialDayOffset(date),
                    verticalPadding: verticalPadding,
                    dayHeight: dayHeight,
                    color: color,
                    canvasSize: size,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaintYear extends CustomPainter {
  _PaintYear({
    @required this.dateUtil,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.dayOffset,
    @required this.verticalPadding,
    @required this.dayHeight,
    @required this.color,
    @required this.canvasSize,
  });

  final DateUtil dateUtil;
  final int year;
  final int month;
  final int day;
  final int dayOffset;
  final double verticalPadding;
  final double dayHeight;
  final Color color;
  final Size canvasSize;

  bool isDayInCurrentMonth(double day) {
    int daysInPreviousMonths = 0;
    int daysInCurrentMonth = dateUtil.daysInMonth(month, year);
    for (var i = 1; i < month; i++) {
      daysInPreviousMonths += dateUtil.daysInMonth(i, year);
    }
    return day > daysInPreviousMonths &&
        day <= daysInPreviousMonths + daysInCurrentMonth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double lineCount = 371;
    final int daysInYear = dateUtil.leapYear(year) ? 366 : 365;
    final int daysPastInYear = dateUtil.daysPastInYear(
      month,
      day,
      year,
    );
    final double strokeWidth = 4;
    final double columnCount = daysInYear / 7;
    final double horizontalPadding = (canvasSize.width / columnCount) - 1.2;

    double yOffset = 0;
    double xOffset = 0;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    for (double i = 0; i < lineCount; i++) {
      yOffset++;
      // reset strokeWidth
      linePaint.strokeWidth = strokeWidth;

      if (i < dayOffset) {
        // days from last year
        linePaint.color = color.withAlpha(60);
        linePaint.strokeWidth = strokeWidth / 2;
      } else if (i < daysPastInYear + dayOffset - 1) {
        // days past in current year
        linePaint.color = color.withAlpha(60);
      } else if (i > daysInYear + dayOffset) {
        // days in next year
        linePaint.color = color.withAlpha(60);
        linePaint.strokeWidth = strokeWidth - 1;
      } else if (isDayInCurrentMonth(i - dayOffset + 1)) {
        // days in current month
        linePaint.color = color.withAlpha(255);
        linePaint.strokeWidth = strokeWidth + 1;
      } else {
        // all other days
        linePaint.color = color.withAlpha(180);
      }

      if (isInteger(i / 7)) {
        xOffset = xOffset + horizontalPadding;
        yOffset = 0;
      }

      double nextXOffset = xOffset;
      double nextYOffset = dayHeight * yOffset;
      double topPoint = nextYOffset + verticalPadding;
      Offset topOffset = Offset(nextXOffset, topPoint);
      double bottomPoint = nextYOffset + dayHeight;
      Offset bottomOffset = Offset(nextXOffset, bottomPoint);

      canvas.drawLine(
        topOffset,
        bottomOffset,
        linePaint,
      );
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

class DayLabels extends StatelessWidget {
  const DayLabels({
    @required this.fontSize,
    @required this.dayHeight,
    @required this.currentDay,
    @required this.color,
    @required this.days,
  });
  final double fontSize;
  final double dayHeight;
  final int currentDay;
  final Color color;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontSize: fontSize);
    final List<Widget> dayWidgets = [];

    for (var i = 0; i < days.length; i++) {
      if (i - 1 == currentDay) {
        style = style.copyWith(color: color.withAlpha(255));
      } else {
        style = style.copyWith(color: color.withAlpha(100));
      }
      dayWidgets.add(Container(
        height: dayHeight,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Text(
          days[i].substring(0, 1),
          style: style,
        ),
      ));
    }

    return Column(
      children: dayWidgets,
    );
  }
}
