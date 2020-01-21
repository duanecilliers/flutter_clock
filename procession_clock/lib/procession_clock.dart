// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:date_util/date_util.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';

enum _Element {
  background,
  text,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

class ProcessionClock extends StatefulWidget {
  const ProcessionClock(this.model);

  final ClockModel model;

  @override
  _ProcessionClockState createState() => _ProcessionClockState();
}

class _ProcessionClockState extends State<ProcessionClock> {
  // DateTime _dateTime = DateTime.now();
  DateTime _dateTime = DateTime(2020, 1, 1);

  Timer _timer;
  DateUtil dateUtil = new DateUtil();

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(ProcessionClock oldWidget) {
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
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      // This is demo code, uncomment to witness
      // _dateTime = DateTime(2020, month, day++, hour++, minute++);

      _dateTime = DateTime.now();
      dateUtil = new DateUtil();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      // Once per second, for demo purposes
      // _timer = Timer(
      //   Duration(milliseconds: 50),
      //   // Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final dayOfWeek = DateFormat('EEEE').format(_dateTime).toUpperCase();
    final month = DateFormat('MMMM').format(_dateTime).toUpperCase();

    return Container(
      color: colors[_Element.background],
      child: AspectRatio(
        aspectRatio: 5 / 3,
        child: Container(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final height = constraints.minHeight;
              final width = constraints.minWidth;
              final dockHeight = height / 10;
              final calendarHeight = height - dockHeight;

              final fontSize = height / 8;
              final int daysInYear =
                  dateUtil.leapYear(_dateTime.year) ? 366 : 365;
              final int daysPastInYear = dateUtil.daysPastInYear(
                _dateTime.month,
                _dateTime.day,
                _dateTime.year,
              );
              final double percentComplete = daysPastInYear / daysInYear * 100;
              final defaultStyle = TextStyle(
                color: colors[_Element.text],
                fontFamily: 'NotoSansCondensed',
                fontSize: fontSize,
              );
              final dateFontStyle = TextStyle(
                fontSize: fontSize / 3.2,
              );

              return DefaultTextStyle(
                style: defaultStyle,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Calendar(
                        date: _dateTime,
                        dateUtil: dateUtil,
                        color: colors[_Element.text],
                        size: Size(width, calendarHeight),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 25,
                      child: Text('$hour:$minute'),
                    ),
                    Positioned(
                      right: 30,
                      bottom: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '$dayOfWeek, ${_dateTime.day} $month',
                            style: dateFontStyle,
                          ),
                          Text(
                            '${percentComplete.round()}% COMPLETE',
                            style: dateFontStyle.copyWith(
                              color: colors[_Element.text].withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
