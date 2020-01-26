import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
//import './widgets.dart';

//class OffScreenBluetooth extends StatelessWidget {
//  const OffScreenBluetooth({Key key, this.state}) : super(key: key);
//
//  final BluetoothState state;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.lightBlue,
//      body: Center(
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            Icon(
//              Icons.bluetooth_disabled,
//              size: 200.0,
//              color: Colors.white54,
//            ),
//            Text(
//              'Bluetooth Adapter is ${state.toString().substring(15)}.',
//              style: Theme.of(context)
//                  .primaryTextTheme
//                  .subhead
//                  .copyWith(color: Colors.white),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
//class DeviceScreen extends StatelessWidget{
//  const DeviceScreen({Key key, this.device}) : super(key: key);
//
//  final BluetoothDevice device;
//  static String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
//  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
//
//  String _dataParser(List<int> dataFromDevice) {
//    return utf8.decode(dataFromDevice);
//  }
//
//  readData(List<BluetoothService> services)async{
//    List <int> value;
//    BluetoothCharacteristic character;
//    services.forEach((service) async {
//      if(service.uuid.toString() == SERVICE_UUID) {
//        character = service.characteristics[0];
//        if(character == null) return;
//        print(character.uuid.toString());
//        value = await character.read();
//        print('VALUE' + _dataParser(value));
//        character.setNotifyValue(true);
//      }
//    });
//  }
//
//  writeData(String data) async{
//    BluetoothCharacteristic character;
//    List<BluetoothService> services = await device.discoverServices();
//    services.forEach((service) async {
//      if(service.uuid.toString() == SERVICE_UUID) {
//        character = service.characteristics[1];
//        print(character.uuid.toString());
//        if(character == null) return;
//        character.write(utf8.encode(data));
//        print('WROTE' + data);
//        character.setNotifyValue(true);
//      }
//    });
//  }
//
//  Widget _myService(List<BluetoothService> services) {
//    Stream<List<int>> stream;
//    print(services.length);
//    BluetoothCharacteristic character;
//    services.forEach((service) async {
//      if(service.uuid.toString() == SERVICE_UUID) {
//        character = service.characteristics[0];
//        print(character.uuid.toString());
//        stream = await character.value;
//        character.setNotifyValue(true);
//      }
//    });
//
//    print('stream' + stream.toString());
//
//    return Container(
//      child: StreamBuilder<List<int>>(
//        stream: stream,
//        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
//          if (snapshot.hasError) return Text('Error : ${snapshot.error}');
//          print('snapshot' + snapshot.connectionState.toString());
//          print('connection state' + ConnectionState.active.toString());
//          if (snapshot.connectionState == ConnectionState.active) {
//            var currentValue = _dataParser(snapshot.data);
//            print('CURRENTVALUE' + currentValue);
//            return new Center(
//              child: Text(currentValue),
//            );
//          } else {
//            return Text('Check the stream');
//          }
//        }),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(device.name),
//        actions: <Widget>[
//          StreamBuilder<BluetoothDeviceState>(
//            stream: device.state,
//            initialData: BluetoothDeviceState.connecting,
//            builder: (c, snapshot) {
//              VoidCallback onPressed;
//              String text;
//              switch (snapshot.data) {
//                case BluetoothDeviceState.connected:
//                  onPressed = () => device.disconnect();
//                  text = 'DISCONNECT';
//                  break;
//                case BluetoothDeviceState.disconnected:
//                  onPressed = () => device.connect();
//                  text = 'CONNECT';
//                  break;
//                default:
//                  onPressed = null;
//                  text = snapshot.data.toString().substring(21).toUpperCase();
//                  break;
//              }
//              return FlatButton(
//                  onPressed: onPressed,
//                  child: Text(
//                    text,
//                    style: Theme.of(context)
//                        .primaryTextTheme
//                        .button
//                        .copyWith(color: Colors.white),
//                  ));
//            },
//          )
//        ],
//      ),
//      body: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            StreamBuilder<BluetoothDeviceState>(
//              stream: device.state,
//              initialData: BluetoothDeviceState.connecting,
//              builder: (c, snapshot) => ListTile(
//                leading: (snapshot.data == BluetoothDeviceState.connected)
//                    ? Icon(Icons.bluetooth_connected)
//                    : Icon(Icons.bluetooth_disabled),
//                title: Text(
////                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
//                      'Device is ${device.name}'),
//                subtitle: Text(device.name),
//                trailing: StreamBuilder<bool>(
//                  stream: device.isDiscoveringServices,
//                  initialData: false,
//                  builder: (c, snapshot) => IndexedStack(
//                    index: snapshot.data ? 1 : 0,
//                    children: <Widget>[
//                      IconButton(
//                        icon: Icon(Icons.refresh),
//                        onPressed: () => device.discoverServices(),
//                      ),
//                      IconButton(
//                        icon: SizedBox(
//                          child: CircularProgressIndicator(
//                            valueColor: AlwaysStoppedAnimation(Colors.grey),
//                          ),
//                          width: 18.0,
//                          height: 18.0,
//                        ),
//                        onPressed: null,
//                      )
//                    ],
//                  ),
//                ),
//              ),
//            ),
//            StreamBuilder<List<BluetoothService>>(
//              stream: device.services,
//              initialData: [],
//              builder: (c, snapshot) {
//                return readData(snapshot.data);
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
class BLEPage extends StatefulWidget {
//  const BLEPage({Key key}) : super(key: key);

  @override
  _BLEPage createState() => new _BLEPage();
}

class _BLEPage extends State<BLEPage> {
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String TARGET_DEVICE_NAME = "Bluefruit52";
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            writeData("Hi there, ESP32!!");
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        });
      }
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

//  readData(List<BluetoothService> services) async{
//    List <int> value;
//    BluetoothCharacteristic character;
//    services.forEach((service) async {
//      if(service.uuid.toString() == SERVICE_UUID) {
//        character = service.characteristics[0];
//        print(character.uuid.toString());
//        value = await character.read();
//        print('VALUE' + _dataParser(value));
//        character.setNotifyValue(true);
//      }
//    });
//  }


//  @override
//  Widget build(BuildContext context) {
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(connectionText),
//      ),
//
//      body: RefreshIndicator(
//        onRefresh: () =>
//          FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
//          child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 StreamBuilder<List<BluetoothDevice>>(
//                   stream: Stream.periodic(Duration(seconds: 2))
//                     .asyncMap((_) => FlutterBlue.instance.connectedDevices),
//                   initialData: [],
//                   builder: (c, snapshot) => Column (
//                     children: snapshot.data
//                         .map((device) => ListTile(
//                       title: Text(device.name),
//                       subtitle: Text(device.id.toString()),
//                       trailing: StreamBuilder<BluetoothDeviceState>(
//                         stream: device.state,
//                         initialData: BluetoothDeviceState.disconnected,
//                         builder: (c, snapshot) {
//                           if (snapshot.data ==
//                               BluetoothDeviceState.connected) {
//                             return RaisedButton(
//                               child: Text('OPEN'),
//                               onPressed: () => Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           DeviceScreen(device: device))),
//                             );
//                           }
//                           return Text(snapshot.data.toString());
//                         },
//                       ),
//                     ))
//                         .toList(),
//                   ),
//                 ),
//               ]
//             ),
//    ))
//    );
//  }
  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback onDirectionChanged(
        double degrees, double distance) {
      String data =
          "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}";
      print(data);
      writeData(data);
    }

    PadButtonPressedCallback padBUttonPressedCallback(
        int buttonIndex, Gestures gesture) {
      String data = "buttonIndex : ${buttonIndex}";
      print(data);
      writeData(data);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
      ),
      body: Container(
        child: targetCharacteristic == null
            ? Center(
          child: Text(
            "Waiting...",
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            JoystickView(
              onDirectionChanged: onDirectionChanged,
            ),
            PadButtonsView(
              padButtonPressedCallback: padBUttonPressedCallback,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  final TextEditingController _chatController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  void _handleSubmit(String text) {
    _chatController.clear();
    ChatMessage message = new ChatMessage(
        text: text
    );
    setState(() {
      _messages.insert(0, message);
    });

  }

  Widget _chatEnvironment (){
    return IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal:8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(hintText: "Starts typing ..."),
                controller: _chatController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),

                onPressed: ()=> _handleSubmit(_chatController.text),

              ),
            )
          ],
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
          child: _chatEnvironment(),)
      ],
    );
  }
}
const String _name = "bluefruit";

class ChatMessage extends StatelessWidget {
  final String text;

// constructor to get text from textfield
  ChatMessage({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child: new Image.network(
                    "http://res.cloudinary.com/kennyy/image/upload/v1531317427/avatar_z1rc6f.png"),
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(_name, style: Theme
                    .of(context)
                    .textTheme
                    .subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),

                )
              ],
            )
          ],
        )
    );
  }

}