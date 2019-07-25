import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_service_item.dart';

class ExpansionPanelIndex {
  ExpansionPanelIndex({
    this.serviceUUID,
    this.isExpanded = false,
  });

  String serviceUUID;
  bool isExpanded;
}

class BleDeviceServiceList extends StatefulWidget {
  const BleDeviceServiceList(
      {Key key,
      this.services,
      this.wirteCharacteristicUUID,
      this.nofityCharacteristicUUIDs,
      this.onWritePressed,
      this.onReadPressed,
      this.onNotifyPressed})
      : super(key: key);

  @required
  final List<BluetoothService> services;
  final Guid wirteCharacteristicUUID;
  final List<Guid> nofityCharacteristicUUIDs;

  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID) onWritePressed;
  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID) onReadPressed;
  @required
  final void Function(Guid serviceUUID, Guid characteristicUUID)
      onNotifyPressed;

  @override
  _ContainerPageState createState() => _ContainerPageState();
}

class _ContainerPageState extends State<BleDeviceServiceList> {
  List<String> _expansion;

  @override
  void initState() {
    super.initState();
    _expansion = new List<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                var service = widget.services[panelIndex];
                var expansion = _expansion.where((ex) {
                  return ex == service.uuid.toString();
                });

                if (expansion.length == 0 && !isExpanded) {
                  _expansion.add(service.uuid.toString());
                }
                if (isExpanded) {
                  _expansion.remove(service.uuid.toString());
                }
              });
            },
            animationDuration: kThemeAnimationDuration,
            children: widget.services
                .map<ExpansionPanel>((service) => new ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expansion.where((ex) {
                          return ex == service.uuid.toString();
                        }).length >
                        0,
                    headerBuilder: (BuildContext context, bool isExpanded) =>
                        new ListTile(
                          title: Text("Unkonown Service"),
                          subtitle: Text(service.uuid.toString()),
                        ),
                    body: new Container(
                        height: 300,
                        child: new ListView(
                            children: ListTile.divideTiles(
                                    tiles: service.characteristics
                                        .map((d) => new BleServiceItem(
                                            characteristic: d,
                                            wirteCharacteristicUUID:
                                                widget.wirteCharacteristicUUID,
                                            nofityCharacteristicUUIDs: widget
                                                .nofityCharacteristicUUIDs,
                                            onWritePressed:
                                                widget.onWritePressed,
                                            onReadPressed: widget.onReadPressed,
                                            onNotifyPressed:
                                                widget.onNotifyPressed))
                                        .toList(),
                                    context: context,
                                    color: Colors.black45)
                                .toList()))))
                .toList(),
          ),
        ],
      ),
    );
  }
}
