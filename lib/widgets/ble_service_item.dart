import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../widgets/hide_IconButton.dart';

class BleServiceItem extends StatelessWidget {
  const BleServiceItem(
      {Key key,
      this.wirteCharacteristicUUID,
      this.nofityCharacteristicUUIDs,
      this.characteristic,
      this.onWritePressed,
      this.onReadPressed,
      this.onNotifyPressed})
      : super(key: key);

  @required
  final BluetoothCharacteristic characteristic;
  final Guid wirteCharacteristicUUID;
  final List<Guid> nofityCharacteristicUUIDs;

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
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Expanded(
                  child: VisibleIconButton(
                    visible: characteristic.properties.write,
                    icon: Icon(Icons.file_upload,
                        color: wirteCharacteristicUUID == characteristic.uuid
                            ? Colors.blue
                            : Colors.black38),
                    onPressed: () {
                      onWritePressed(this.characteristic.serviceUuid,
                          this.characteristic.uuid);
                    },
                  ),
                  flex: 1,
                ),
                Expanded(
                    child: VisibleIconButton(
                      visible: characteristic.properties.read,
                      icon: Icon(Icons.file_download, color: Colors.black38),
                      onPressed: () {
                        onReadPressed(this.characteristic.serviceUuid,
                            this.characteristic.uuid);
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: VisibleIconButton(
                      visible: characteristic.properties.notify,
                      icon: Icon(Icons.notifications_none,
                          color: nofityCharacteristicUUIDs
                                      .indexOf(characteristic.uuid) >=
                                  0
                              ? Colors.blue
                              : Colors.black38),
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
