import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LogItem {
  LogItem({this.time, this.msg});

  String time;
  String msg;
}

class BleLogs extends StatelessWidget {
  const BleLogs({Key key, this.logs}) : super(key: key);
  final List<LogItem> logs;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: logs.map((log) {
        return new Row(
          children: <Widget>[
            new Text(
              log.time + " > ",
              style: new TextStyle(color: Colors.black26),
            ),
            new Text(
              log.msg,
              softWrap: true,
            )
          ],
        );
      }).toList(),
    );
  }
}
