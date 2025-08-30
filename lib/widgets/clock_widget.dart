import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentTimeWidget extends StatefulWidget {
  final TextStyle? textStyle;
  final String timeFormat;

  const CurrentTimeWidget({
    Key? key,
    this.textStyle,
    this.timeFormat = 'hh:mm:ss a', // Default format: 12-hour with AM/PM
  }) : super(key: key);

  @override
  _CurrentTimeWidgetState createState() => _CurrentTimeWidgetState();
}

class _CurrentTimeWidgetState extends State<CurrentTimeWidget> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat(widget.timeFormat).format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: widget.textStyle ?? Theme.of(context).textTheme.headlineSmall,
    );
  }
}
