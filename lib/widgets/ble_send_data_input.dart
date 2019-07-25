import 'package:flutter/material.dart';

class SendDataInput extends StatelessWidget {
  const SendDataInput({Key key, this.enable, this.onPressed, this.onChanged})
      : super(key: key);

  final bool enable;
  final VoidCallback onPressed;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.text_fields),
              labelText: '请输入要发送的数据)',
              helperText: '数据格式:aa00bb11cc22',
            ),
          ),
        ),
        Container(
          width: 20,
        ),
        MaterialButton(
          color: Colors.blue,
          textColor: Colors.white,
          child: new Text('提交'),
          onPressed: enable ? this.onPressed : null,
        )
      ],
    );
  }
}
