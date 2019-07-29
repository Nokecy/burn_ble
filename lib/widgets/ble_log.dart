import 'package:flutter/material.dart';

class LogItem {
  LogItem({this.time, this.msg});

  String time;
  String msg;
}

class BleLogs extends StatelessWidget {
  const BleLogs({Key key, this.logs, this.onClearPressed}) : super(key: key);
  final List<LogItem> logs;
  final VoidCallback onClearPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("清空日志"),
              onPressed: this.onClearPressed,
            )
          ],
        ),
        Column(
          children: logs.asMap().keys.map((i) {
            var log = logs[i];
            return new Row(
              children: <Widget>[
                new Text(
                  log.time + " > ",
                  style: new TextStyle(color: Colors.black26),
                ),
                Expanded(
                  child: Text(
                    log.msg,
                    softWrap: true,
                    style: TextStyle(
                        color: i % 2 != 0 ? Colors.black : Colors.red[300]),
                  ),
                )
              ],
            );
          }).toList(),
        )
      ],
    );
  }
}
