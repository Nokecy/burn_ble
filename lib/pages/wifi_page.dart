import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:smartconfig/smartconfig.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    showDialog(
      // 传入 context
      context: context,
      barrierDismissible: false, // 屏蔽点击对话框外部自动关闭
      // 构建 Dialog 的视图
      builder: (_) => WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('正在执行配网,请稍后',
                        style: TextStyle(
                            fontSize: 12, decoration: TextDecoration.none)),
                  ),
                  SpinKitWave(
                      color: Colors.yellow, type: SpinKitWaveType.center),
                ],
              ),
            )
          ],
        ),
      ),
    );

    Smartconfig.start(_wifiName, _wifiBSSID, _passWord).then((onValue) {
      Navigator.pop(context);
      if (onValue != null) {
        showToast("配网成功!" + onValue);
      } else {
        showToast("配网失败!");
      }
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
