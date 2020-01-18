import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    @required this.dateUtil,
  });

  final DateUtil dateUtil;

  @override
  _Calendar createState() => _Calendar();
}

class _Calendar extends State<Calendar> {
  final monthsPerYear = DateTime.monthsPerYear;
  final daysPerWeek = DateTime.daysPerWeek;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BuildMonth(
        dateUtil: widget.dateUtil,
        year: 2020,
        month: 1,
      ),
    );
  }
}

//
///@todo track last day point from previously painted month
//
class BuildMonth extends StatelessWidget {
  const BuildMonth({
    @required this.dateUtil,
    @required this.year,
    @required this.month,
  });

  final DateUtil dateUtil;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    int daysInMonth = dateUtil.daysInMonth(this.month, this.year);

    return Container(
			child: CustomPaint(painter: _PaintMonth(dateUtil: dateUtil, year: year, month: month),),
      // child: Text('monthsPerYear: $monthsPerYear'),
      // child: Text('daysInMonth: $daysInMonth'),
      // child: BuildWeek(),
    );
  }
}

class _PaintMonth extends CustomPainter {
	_PaintMonth({
		@required this.dateUtil,
		@required this.year,
		@required this.month,
	});

	final DateUtil dateUtil;
	final int year;
	final int month;

	bool isInteger(num value) =>
    value is int || value == value.roundToDouble();

	@override void paint(Canvas canvas, Size size) {
		final daysInMonth = dateUtil.daysInMonth(month, year);
		final double dayLineHeight = 40;
		final double verticalSpacing = 10;
		final double weekPadding = 16;

		final linePaint = Paint()
			..color = Color(0xFFFFFFFF)
			..style = PaintingStyle.stroke
			..strokeWidth = 2
			..strokeCap = StrokeCap.square;

		double lastXOffset = 0;
		double lastYOffset = 0;

		for (double i = 0; i < daysInMonth; i++) {
			lastYOffset++;
			if (this.isInteger(i / 7)) {
				lastXOffset = i / 7 * weekPadding;
				lastYOffset = 0;
			}

			double nextXOffset = lastXOffset + weekPadding;
			double nextYOffset = (dayLineHeight * lastYOffset);
			double topPoint = nextYOffset + verticalSpacing;
			Offset topOffset = Offset(nextXOffset, topPoint);
			double bottomPoint = nextYOffset + dayLineHeight;
			Offset bottomOffset = Offset(nextXOffset, bottomPoint);

			canvas.drawLine(topOffset, bottomOffset, linePaint);
		}
	}

	@override
  bool shouldRepaint(_PaintMonth oldDelegate) {
		return oldDelegate.year != year ||
				oldDelegate.month != month;
	}
}
