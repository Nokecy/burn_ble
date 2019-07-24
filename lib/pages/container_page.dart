import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetoothOffScreen.dart';
import '../widgets/ble_list.dart';
import './device_service_page.dart';

class ContainerPage extends StatefulWidget {
  ContainerPage({Key key}) : super(key: key);

  @override
  _ContainerPageState createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("蓝牙助手"),
          leading: new Icon(Icons.home),
          actions: <Widget>[
            StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  final isScanning = snapshot.data;
                  return new IconButton(
                    icon: new Icon(Icons.refresh, color: Colors.black38),
                    onPressed: isScanning == true
                        ? null
                        : () => {
                              FlutterBlue.instance
                                  .startScan(timeout: Duration(seconds: 4))
                            },
                  );
                })
          ],
        ),
        body: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.off) {
                return new BluetoothOffScreen(
                  state: state,
                );
              }
              return new RefreshIndicator(
                onRefresh: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)),
                child: new BleDeviceList(
                    onPressed: (device) => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                DeviceServicePage(device: device)))),
              );
            }));
  }
}
