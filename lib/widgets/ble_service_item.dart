import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oktoast/oktoast.dart';

class BleServiceItem extends StatelessWidget {
  const BleServiceItem(
      {Key key,
      this.characteristic,
      this.onWritePressed,
      this.onReadPressed,
      this.onNotifyPressed})
      : super(key: key);

  @required
  final BluetoothCharacteristic characteristic;

  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID) onWritePressed;
  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID) onReadPressed;
  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID)
      onNotifyPressed;

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
      title: Text("Unkonown Characteristic"),
      subtitle: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "UUID：" + this.characteristic.uuid.toString(),
              style: TextStyle(fontSize: 12),
            ),
            Text(
              "属性：" + this.getCharacteristicProperties(),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: Container(
        height: 48,
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.file_upload, color: Colors.black38),
                    onPressed: () {
                      onWritePressed(this.characteristic.serviceUuid,
                          this.characteristic.uuid);
                    },
                  ),
                  flex: 1,
                ),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.file_download, color: Colors.black38),
                      onPressed: () {
                        onReadPressed(this.characteristic.serviceUuid,
                            this.characteristic.uuid);
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: IconButton(
                      icon:
                          Icon(Icons.notifications_none, color: Colors.black38),
                      onPressed: () {
                        onNotifyPressed(this.characteristic.serviceUuid,
                            this.characteristic.uuid);
                      },
                    ),
                    flex: 1),
              ],
            )
          ],
        ),
      ),
      onTap: null,
    );
  }
}
