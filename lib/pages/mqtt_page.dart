import 'package:flutter/material.dart';
import '../util/mqtt/mqtt_stream.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttPage extends StatefulWidget {
  MqttPage({this.title});
  final String title;

  @override
  MqttPageState createState() => MqttPageState();
}

class MqttPageState extends State<MqttPage> {
  final myTopicController = TextEditingController();
  final myValueController = TextEditingController();

  String _textValue;

  @override
  void initState() {
    AppMqttTransactions.instance.connectToClient().then((value) {
      if (value) {
        AppMqttTransactions.instance.updates
            .listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload;
          final String pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          setState(() {
            _textValue = pt;
          });
        });
      }
    });
    _textValue = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: _body(),
    );
  }

  //
  // The body of the page.  The children contain the main components of
  // the UI.
  Widget _body() {
    return Column(
      children: <Widget>[
        _subscriptionInfo(),
        _subscriptionData(),
        _publishInfo(),
      ],
    );
  }

//
// The UI to get and subscribe to the mqtt topic.
//
  Widget _subscriptionInfo() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Topic:',
                style: TextStyle(fontSize: 24),
              ),
              // To use TextField within a row, it needs to be wrapped in a Flexible
              // widget.  See Stackoverflow: https://bit.ly/2IkzqBk
              Flexible(
                child: TextField(
                  controller: myTopicController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter topic to subscribe to',
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Text('Subscribe'),
            onPressed: () {
              subscribe(myTopicController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _subscriptionData() {
    return Text(_textValue);
  }

  Widget _publishInfo() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Value:',
                style: TextStyle(fontSize: 24),
              ),
              // To use TextField within a row, it needs to be wrapped in a Flexible
              // widget.  See Stackoverflow: https://bit.ly/2IkzqBk
              Flexible(
                child: TextField(
                  controller: myValueController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter value to publish',
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Text('Publish'),
            onPressed: () {
              publish(myTopicController.text, myValueController.text);
            },
          ),
        ],
      ),
    );
  }

  void subscribe(String topic) {
    AppMqttTransactions.instance.subscribe(topic);
  }

  void publish(String topic, String value) {
    AppMqttTransactions.instance.publish(topic, value);
  }
}
