import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({@required this.color, @required this.size});
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final dateUtil = DateUtil();
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
									verticalPadding: verticalPadding,
									dayHeight: dayHeight,
                  color: color,
                  canvasSize: size,
                )),
              )
            ],
          )
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
		@required this.verticalPadding,
		@required this.dayHeight,
    @required this.color,
    @required this.canvasSize,
  });

  final DateUtil dateUtil;
  final int year;
  final int month;
  final int day;
	final double verticalPadding;
	final double dayHeight;
  final Color color;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    final double lineCount = 371;
    final int daysInYear = dateUtil.leapYear(year) ? 366 : 365;
    final int daysPastInYear = dateUtil.daysPastInYear(month, day, year);
    final double strokeWidth = 2;
    final double columnCount = daysInYear / 7;
    final double horizontalPadding = (canvasSize.width / columnCount) - 1;

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
      double nextYOffset = dayHeight * yOffset;
      double topPoint = nextYOffset + verticalPadding;
      Offset topOffset = Offset(nextXOffset, topPoint);
      double bottomPoint = nextYOffset + dayHeight;
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

class DayLabels extends StatelessWidget {
  const DayLabels(
      {@required this.fontSize,
      @required this.dayHeight,
      @required this.currentDay,
      @required this.color});
  final double fontSize;
  final double dayHeight;
  final int currentDay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontSize: fontSize);
    final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
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
          days[i],
          style: style,
        ),
      ));
    }

    return Column(
      children: dayWidgets,
    );
  }
}
