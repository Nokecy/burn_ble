import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_list_item.dart';

class BleDeviceList extends StatelessWidget {
  const BleDeviceList({Key key, this.onPressed}) : super(key: key);

  @required
  final void Function(BluetoothDevice) onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (c, snapshot) => new ListView(
          children: ListTile.divideTiles(
                  tiles: snapshot.data
                      .map((d) => new BleListItem(
                            device: d.device,
                            onPressed: () => this.onPressed(d.device),
                          ))
                      .toList(),
                  context: context,
                  color: Colors.black45)
              .toList()),
    );
  }
}
