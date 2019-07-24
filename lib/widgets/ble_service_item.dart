import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleServiceItem extends StatelessWidget {
  const BleServiceItem({Key key, this.characteristic, this.onPressed})
      : super(key: key);

  @required
  final BluetoothCharacteristic characteristic;

  @required
  final void Function() onPressed;

  String getCharacteristicProperties() {
    String text = "";
    if (characteristic.properties.broadcast) {
      text += "broadcast，";
    }
    if (characteristic.properties.read) {
      text += "read，";
    }
    if (characteristic.properties.write) {
      text += "write，";
    }
    if (characteristic.properties.notify) {
      text += "notify，";
    }
    if (characteristic.properties.indicate) {
      text += "indicate，";
    }
    if (characteristic.properties.authenticatedSignedWrites) {
      text += "authenticatedSignedWrites，";
    }
    if (characteristic.properties.extendedProperties) {
      text += "extendedProperties，";
    }
    if (characteristic.properties.notifyEncryptionRequired) {
      text += "notifyEncryptionRequired，";
    }
    if (characteristic.properties.indicateEncryptionRequired) {
      text += "indicateEncryptionRequired，";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("UUID：" + this.characteristic.uuid.toString()),
      subtitle: Text("属性：" + this.getCharacteristicProperties()),
      trailing: new Icon(Icons.arrow_right, color: Colors.black38),
      onTap: () => this.onPressed(),
    );
  }
}
