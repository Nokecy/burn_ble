import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:smartconfig/smartconfig.dart';
import 'package:oktoast/oktoast.dart';

class WifiPage extends StatefulWidget {
  WifiPage({Key key}) : super(key: key);

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  StreamSubscription<ConnectivityResult> subscription;

  ConnectivityResult _connectivity;
  String _wifiBSSID;
  String _wifiName;
  String _passWord;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      String bssid;
      String name;
      if (result == ConnectivityResult.wifi) {
        bssid = await Connectivity().getWifiBSSID();
        name = await Connectivity().getWifiName();
      }
      setState(() {
        _connectivity = result;
        _wifiBSSID = bssid;
        _wifiName = name;
      });
    });
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  void onChanged(String value) {
    setState(() {
      _passWord = value;
    });
  }

  void onPressed() {
    Smartconfig.start(_wifiName, _wifiBSSID, _passWord).then((onValue) {
      if (onValue != null) {
        showToast("配置失败!");
      } else {
        showToast("配置成功!");
      }
      print("sm version $onValue");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wifi配置"),
          leading: new Icon(Icons.wifi),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            _connectivity != ConnectivityResult.wifi
                ? Text("请连接Wifi")
                : Text("已连接wifi  名称: " + _wifiName + " BSSID: " + _wifiBSSID),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextField(
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      icon: Icon(Icons.text_fields),
                      labelText: '请输入连接WIFI密码)',
                      helperText: '请输入连接WIFI密码',
                    ),
                  ),
                ),
                Container(
                  width: 20,
                ),
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: new Text('配置'),
                  onPressed: _connectivity == ConnectivityResult.wifi
                      ? this.onPressed
                      : null,
                )
              ],
            )
          ],
        )));
  }
}
