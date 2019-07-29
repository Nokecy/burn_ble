import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
// import 'Adafruit_feed.dart';

class AppMqttTransactions {
  Logger log;
  MqttClient client;

  AppMqttTransactions._() {
    log = Logger('mqtt_stream.dart');
  }

  static AppMqttTransactions _instance = new AppMqttTransactions._();
  static AppMqttTransactions get instance => _instance;

  Stream<List<MqttReceivedMessage<MqttMessage>>> get updates =>
      client != null ? client.updates : null;

  Future<bool> subscribe(String topic) async {
    if (await connectToClient() == true) {
      /// 添加断开连接回调
      client.onDisconnected = _onDisconnected;

      /// 添加连接成功回调
      client.onConnected = _onConnected;

      ///添加订阅成功回调
      client.onSubscribed = _onSubscribed;
      //订阅主题
      _subscribe(topic);
    }
    return true;
  }

  //连接到Server
  Future<bool> connectToClient() async {
    if (client != null &&
        client.connectionStatus.state == MqttConnectionState.connected) {
      log.info('already logged in');
    } else {
      client = await _login();
      if (client == null) {
        return false;
      }
    }
    return true;
  }

  /// 订阅回调
  void _onSubscribed(String topic) {
    log.info('Subscription confirmed for topic $topic');
  }

  /// 断开连接回调
  void _onDisconnected() {
    log.info('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      log.info(':OnDisconnected callback is solicited, this is correct');
    }
    client.disconnect();
  }

  /// 连接成功回调
  void _onConnected() {
    log.info('OnConnected client callback - Client connection was sucessful');
  }

  Future<Map> _getBrokerAndKey() async {
    String connect =
        await rootBundle.loadString('config/private.json', cache: false);
    return (json.decode(connect));
  }

  Future<MqttClient> _login() async {
    Map connectJson = await _getBrokerAndKey();
    // TBD Test valid broker and key
    log.info('in _login....broker  : ${connectJson['broker']}');
    log.info('in _login....key     : ${connectJson['key']}');
    log.info('in _login....username: ${connectJson['username']}');

    client = MqttClient(connectJson['broker'], connectJson['key']);
    // Turn on mqtt package's logging while in test.
    client.logging(on: true);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(connectJson['username'], connectJson['key'])
        .withClientIdentifier('myClientID')
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    log.info('Adafruit client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.
    try {
      await client.connect();
    } on Exception catch (e) {
      log.severe('EXCEPTION::client exception - $e');
      client.disconnect();
      client = null;
      return client;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      log.info('Adafruit client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      log.info(
          'Adafruit client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      client = null;
    }
    return client;
  }

  Future _subscribe(String topic) async {
    log.info('Subscribing to the topic $topic');
    client.subscribe(topic, MqttQos.atMostOnce);
    // client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //   final MqttPublishMessage recMess = c[0].payload;
    //   final String pt =
    //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    //   // AdafruitFeed.add(pt);
    //   log.info(
    //       'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    //   return pt;
    // });
  }

  Future<void> publish(String topic, String value) async {
    if (await connectToClient() == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
    }
  }
}
