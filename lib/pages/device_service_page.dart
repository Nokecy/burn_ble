import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../widgets/ble_service_list.dart';
import '../widgets/ble_log.dart';
import 'package:oktoast/oktoast.dart';

class DeviceServicePage extends StatefulWidget {
  DeviceServicePage({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceServicePageState createState() => _DeviceServicePageState();
}

class _DeviceServicePageState extends State<DeviceServicePage> {
  List<BluetoothService> _services = [];
  List<LogItem> _logs = [];

  StreamSubscription<BluetoothDeviceState> _stateStreamSubscription;
  StreamSubscription<List<BluetoothService>> _serviceStreamSubscription;

  void onStateData(BluetoothDeviceState state) {
    if (state == BluetoothDeviceState.connected) {
      try {
        setState(() {
          _logs.add(new LogItem(
              msg: "连接成功,正在发现服务...", time: DateTime.now().toString()));
        });
        widget.device.discoverServices();
      } catch (e) {}
      showToast("连接成功!");
    }
    if (state == BluetoothDeviceState.disconnected) {
      showToast("连接断开!");
      setState(() {
        _logs.add(new LogItem(msg: "连接断开...", time: DateTime.now().toString()));
      });
    }
  }

  void onServiceData(List<BluetoothService> services) {
    setState(() {
      _services = services;
      if (services.length > 0) {
        _logs.add(new LogItem(
            msg: "发现" + services.length.toString() + "个服务",
            time: DateTime.now().toString()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _stateStreamSubscription = widget.device.state.listen(this.onStateData);
    _serviceStreamSubscription =
        widget.device.services.listen(this.onServiceData);
  }

  @override
  void dispose() {
    super.dispose();
    _stateStreamSubscription.cancel();
    _serviceStreamSubscription.cancel();
    widget.device.disconnect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.device.connect(autoConnect: false, timeout: Duration(seconds: 10));
    setState(() {
      _logs.add(new LogItem(msg: "正在连接...", time: DateTime.now().toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: new ListTile(
              title: new Text(widget.device.name),
              subtitle: new Text(widget.device.id.toString()),
            ),
            bottom: new TabBar(
              tabs: <Widget>[
                new Tab(
                  icon: new Icon(Icons.bluetooth),
                  text: "蓝牙服务",
                ),
                new Tab(
                  icon: new Icon(Icons.audiotrack),
                  text: "实时日志",
                ),
              ],
            ),
            actions: <Widget>[
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  VoidCallback onPressed;
                  String text;
                  switch (snapshot.data) {
                    case BluetoothDeviceState.connected:
                      onPressed = () => widget.device.disconnect();
                      text = '断开';
                      break;
                    case BluetoothDeviceState.disconnected:
                      onPressed = () => widget.device.connect();
                      text = '连接';
                      break;
                    default:
                      onPressed = null;
                      text =
                          snapshot.data.toString().substring(21).toUpperCase();
                      break;
                  }
                  return FlatButton(
                      onPressed: onPressed,
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .button
                            .copyWith(color: Colors.white),
                      ));
                },
              )
            ],
          ),
          body: new TabBarView(
            children: <Widget>[
              new SingleChildScrollView(
                  child: new BleDeviceServiceList(
                services: this._services,
              )),
              new SingleChildScrollView(
                  child: new BleLogs(
                logs: _logs,
              )),
            ],
          ),
        ));
  }
}
