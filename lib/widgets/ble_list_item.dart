import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleListItem extends StatelessWidget {
  const BleListItem({Key key, this.device, this.onPressed}) : super(key: key);

  @required
  final BluetoothDevice device;

  @required
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this.device.name),
      subtitle: Text(this.device.id.id),
      trailing: new Icon(Icons.arrow_right, color: Colors.black38),
      onTap: () => this.onPressed(),
    );
  }
}
