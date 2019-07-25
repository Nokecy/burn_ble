import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../util/index.dart';
import '../widgets/ble_service_list.dart';
import '../widgets/ble_log.dart';
import '../widgets/ble_send_data_input.dart';
import 'package:oktoast/oktoast.dart';

class DeviceServicePage extends StatefulWidget {
  DeviceServicePage({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceServicePageState createState() => _DeviceServicePageState();
}

class _DeviceServicePageState extends State<DeviceServicePage> {
  List<BluetoothService> _services = []; //当前设备服务列表
  List<LogItem> _logs = []; //实时日志
  BluetoothCharacteristic _wirteCharacteristic; //当前选中的写入特征
  Map<BluetoothCharacteristic, StreamSubscription<List<int>>>
      _nofityCharacteristics; //当前选中的写入特征
  StreamSubscription<BluetoothDeviceState> _stateStreamSubscription;
  StreamSubscription<List<BluetoothService>> _serviceStreamSubscription;

  String _currentValue;

  void onStateData(BluetoothDeviceState state) {
    if (state == BluetoothDeviceState.connected) {
      try {
        setState(() {
          _logs.add(new LogItem(
              msg: "连接成功,正在发现服务...",
              time: DateTime.now().toString().substring(0, 19)));
        });
        widget.device.discoverServices();
      } catch (e) {}
      showToast("连接成功!");
    }
    if (state == BluetoothDeviceState.disconnected) {
      showToast("连接断开!");
      setState(() {
        _logs.add(new LogItem(
            msg: "连接断开...", time: DateTime.now().toString().substring(0, 19)));
      });
    }
  }

  void onServiceData(List<BluetoothService> services) {
    setState(() {
      _services = services;
      if (services.length > 0) {
        _logs.add(new LogItem(
            msg: "发现" + services.length.toString() + "个服务",
            time: DateTime.now().toString().substring(0, 19)));
      }
    });
  }

  Future readData(Guid serviceUUID, Guid characteristicUUID) async {
    var service = _services.firstWhere((service) {
      return service.uuid == serviceUUID;
    });
    var characteristic = service.characteristics.firstWhere((chara) {
      return chara.uuid == characteristicUUID;
    });

    List<int> value = await characteristic.read();
    setState(() {
      _logs.add(new LogItem(
          msg: "特征UUID：" +
              characteristic.uuid.toString() +
              ": 读取数据 " +
              value.toString(),
          time: DateTime.now().toString().substring(0, 19)));
    });
  }

  void wirteData(Guid serviceUUID, Guid characteristicUUID) {
    var service = _services.firstWhere((service) {
      return service.uuid == serviceUUID;
    });
    var characteristic = service.characteristics.firstWhere((chara) {
      return chara.uuid == characteristicUUID;
    });
    setState(() {
      _wirteCharacteristic = characteristic;
    });
  }

  Future notifyData(Guid serviceUUID, Guid characteristicUUID) async {
    var service = _services.firstWhere((service) {
      return service.uuid == serviceUUID;
    });
    var characteristic = service.characteristics.firstWhere((chara) {
      return chara.uuid == characteristicUUID;
    });
    var falg = await characteristic.setNotifyValue(!characteristic.isNotifying);

    if (falg) {
      var linsten = characteristic.value.listen((value) {
        setState(() {
          _logs.add(new LogItem(
              msg: characteristic.uuid.toString() + ": 收到" + value.toString(),
              time: DateTime.now().toString().substring(0, 19)));
        });
      });

      setState(() {
        if (_nofityCharacteristics.containsKey(characteristic)) {
          _nofityCharacteristics[characteristic].cancel();

          _nofityCharacteristics.remove(characteristic);
        } else {
          _nofityCharacteristics[characteristic] = linsten;
        }
        _logs.add(new LogItem(
            msg: characteristic.uuid.toString() +
                ": 监听" +
                (characteristic.isNotifying ? "开启" : "关闭"),
            time: DateTime.now().toString().substring(0, 19)));
      });
    }
  }

  void onInpuValueChanged(String value) {
    setState(() {
      _currentValue = value;
    });
  }

  void sendValue() {
    if (_currentValue.length % 2 != 0) {
      showToast("输入格式错误!");
      return;
    }
    var values = stringToHex(_currentValue);
    _wirteCharacteristic.write(values);
    setState(() {
      _logs.add(new LogItem(
          msg:
              _wirteCharacteristic.uuid.toString() + ": 写入" + values.toString(),
          time: DateTime.now().toString().substring(0, 19)));
    });
  }

  @override
  void initState() {
    super.initState();
    _stateStreamSubscription = widget.device.state.listen(this.onStateData);
    _serviceStreamSubscription =
        widget.device.services.listen(this.onServiceData);
    _nofityCharacteristics = new Map();
    _currentValue = "";
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
      _logs.add(new LogItem(
          msg: "正在连接...", time: DateTime.now().toString().substring(0, 19)));
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
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new TabBarView(
                  children: <Widget>[
                    new SingleChildScrollView(
                        child: new BleDeviceServiceList(
                      services: this._services,
                      wirteCharacteristicUUID: _wirteCharacteristic != null
                          ? this._wirteCharacteristic.uuid
                          : null,
                      nofityCharacteristicUUIDs:
                          this._nofityCharacteristics.keys.map((f) {
                        return f.uuid;
                      }).toList(),
                      onWritePressed: this.wirteData,
                      onReadPressed: this.readData,
                      onNotifyPressed: this.notifyData,
                    )),
                    new SingleChildScrollView(
                        child: new BleLogs(
                      logs: _logs,
                      onClearPressed: () => {
                        setState(() {
                          _logs.clear();
                        })
                      },
                    )),
                  ],
                ),
              ),
              SendDataInput(
                enable: _wirteCharacteristic != null,
                onChanged: this.onInpuValueChanged,
                onPressed: this.sendValue,
              )
            ],
          ),
        ));
  }
}
