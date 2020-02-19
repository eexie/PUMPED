import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import './helpers/ProductionDataPoint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class MyAdaScreen extends StatefulWidget {
  @override
  _MyAdaScreen createState() => new _MyAdaScreen();

}
class _MyAdaScreen extends State<MyAdaScreen> {
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  final String TARGET_DEVICE_NAME = "Ada";
  String data = "";
  Stream<List<int>> stream;

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
//
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

  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
      ),
      body: Center(//RefreshIndicator(
//        onRefresh: () =>
//            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return RaisedButton(
                            child: Text('OPEN'),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DeviceScreen(device: d))),
//                              onPressed: () => redirect,
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
//              StreamBuilder<List<ScanResult>>(
//                stream: FlutterBlue.instance.scanResults,
//                initialData: [],
//                builder: (c, snapshot) => Column(
//                  children: snapshot.data
//                      .map(
//                        (r) => ScanResultTile(
//                      result: r,
//                      onTap: () => Navigator.of(context)
//                          .push(MaterialPageRoute(builder: (context) {
//                        r.device.connect();
//                        return DeviceScreen(device: r.device);
//                      })),
//                    ),
//                  )
//                      .toList(),
//                ),
//              ),
            ],
          ),
        ),
      ),
//      floatingActionButton: StreamBuilder<bool>(
//        stream: FlutterBlue.instance.isScanning,
//        initialData: false,
//        builder: (c, snapshot) {
//          if (snapshot.data) {
//            return FloatingActionButton(
//              child: Icon(Icons.stop),
//              onPressed: () => FlutterBlue.instance.stopScan(),
//              backgroundColor: Colors.red,
//            );
//          } else {
//            return FloatingActionButton(
//                child: Icon(Icons.search),
//                onPressed: () => FlutterBlue.instance
//                    .startScan(timeout: Duration(seconds: 4)));
//          }
//        },
//      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceScreen createState() => _DeviceScreen();
}
class _DeviceScreen extends State<DeviceScreen> {
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
  final databaseReference = Firestore.instance;

  List<ProductionDataPoint> sessionTimeSeries = []; //Timeseries for the current pumping session
  bool inLetdown = false;
  int letdownLength = 0;

  // session controls
  int letdownVacuumLvl = 0;
  int vacuumLvl = 0;
  int letdownSpeed = 0;
  bool downPressed = false;

  // session record data
  List<int> vacuumPowerLvls = [0];
  DateTime startTime;
  DateTime endTime;
  int sessionNumber = 0;
  List<String> mood = [];
  CollectionReference sessionCollection;
  DocumentReference newSession;
  DocumentReference sessionControlsReference;

  BluetoothCharacteristic writeCharacteristic;

  @override
  void initState() {
    super.initState();
    getSessionControls();
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  handleReceivedData(String value){
    if(value[0] == 'l'){ // letdown detected
      sessionTimeSeries.clear();
      inLetdown = true;
      letdownLength = DateTime.now().difference(startTime).inSeconds;
      print('letdown detected');
    }
    else if (value[0] == 'v') { // current vacuum level
//      vacuumLvl = int.parse(value.substring(1));
//      print('current vacuum level ${vacuumLvl}');
      print('vacuum changed' + value);
    }
    else if (value[0] == 'e'){ // pumping session ended
      createSessionRecord();
      print('end session, write to firebase');
    }
    else if(double.tryParse(value[0]) != null){ // received data point
      print('volume received');
      print(value);
      var duration = value[0];
      var time = startTime.add(new Duration(seconds: int.parse(duration)));
      var volume = double.parse(value[1]);
      ProductionDataPoint dataPoint = new ProductionDataPoint(time, volume);
      sessionTimeSeries.add(dataPoint);
    }
  }
  String getTimeOfDay (DateTime endTime){
    int sessionHour = endTime.hour;
    if(sessionHour <= 6 && sessionHour > 0){
      return "dawn";
    } else if(sessionHour <= 12 && sessionHour > 6){
      return "morning";
    } else if (sessionHour <= 18 && sessionHour > 12){
      return "afternoon";
    } else {
      return "evening";
    }
  }
  startSession() {
    writeData('s');
    sessionTimeSeries.clear();
    print('start');
    startTime = new DateTime.now();
  }
  endSession(){
    writeData('e');
    print('end');
  }
  changePumpPower(String change){
    writeData('v${change}');
    print("changed pump power ${change}");
    vacuumPowerLvls.add(int.parse(change));
  }
  writeData(String data) {
    if (writeCharacteristic == null) {
      print('no write characteristic');
      return;
    }
    List<int> bytes = utf8.encode(data);
    writeCharacteristic.write(bytes);
  }

  void getSessionControls() async {
    final userDocumentReference = databaseReference.collection("users").document("emily");
    String collectionTitle = startTime.month.toString()
        + '-' + startTime.day.toString()
        + '-' + startTime.year.toString(); //creates a collection of sessions for the day, if it doesn't exist
    sessionCollection = userDocumentReference.collection(collectionTitle);
    String documentTitle = startTime.hour.toString() + '-' + startTime.minute.toString();
    newSession = sessionCollection.document(documentTitle);

    CollectionReference personalizationCollection = userDocumentReference.collection('personalization');
    sessionControlsReference = personalizationCollection.document('sessionControls');

    databaseReference.runTransaction((transaction) async{

      //get count of # of sessions in collection
      await sessionCollection.getDocuments().then((value) {
        sessionNumber = value.documents.length + 1;
        print('documents ${value.documents.length}');
      });

      //get last session data to determine current session's controls
      await transaction.get(sessionControlsReference).then((value) {
        vacuumLvl = value.data['vacuumPower'];
        letdownSpeed = value.data['letdownSpeed'];
        letdownVacuumLvl = value.data['letdownVacuum'];
      });
    });
  }
  void createSessionRecord() async {
    print('creating record');
    DateTime endTime = DateTime.now();

    String timeOfDay = getTimeOfDay(endTime);
    int sessionLength = endTime.difference(startTime).inSeconds;

    SessionData sessionRecord = new SessionData(sessionTimeSeries,
        letdownLength,
        vacuumPowerLvls.toSet().toList(),
        sessionLength,
        timeOfDay,
        endTime,
        sessionNumber,
        mood,
    );
    int sessionVacuumMaxLvl = vacuumPowerLvls.reduce(max);
    sessionVacuumMaxLvl = downPressed ? sessionVacuumMaxLvl -=2 : sessionVacuumMaxLvl;

    // write document first
    databaseReference.runTransaction((transaction) async{
      await transaction.set(newSession, sessionRecord.toMap());
      print('got database reference');

      // if user was ok with a higher vacuum power setting this session, record it
      if (sessionVacuumMaxLvl > vacuumLvl){
        vacuumLvl = sessionVacuumMaxLvl;
        await transaction.set(sessionControlsReference, {'vacuumPower': vacuumPowerLvls});
      }

      sessionRecord.sessionNumber = sessionNumber;
      await transaction.set(newSession, sessionRecord.toMap());
      print("wrote data");
    });
  }
  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    print('services length ${services.length}');
    List<BluetoothService> targetServices = [];
    List<BluetoothCharacteristic> targetCharacteristics = [];
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        targetServices.add(service);
      }
    });
    targetCharacteristics = targetServices[0].characteristics;
    targetCharacteristics[0].setNotifyValue(true);

    BluetoothCharacteristic readCharacteristic = targetCharacteristics[0];
    writeCharacteristic = targetCharacteristics[1];
    return [
      StreamBuilder<List<int>>(
      stream: readCharacteristic.value,
      initialData: readCharacteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        if(value.isNotEmpty) handleReceivedData(_dataParser(value));
        return ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Characteristic'),
              Text(
                  '0x${readCharacteristic.uuid.toString()}',
                  style: Theme.of(context).textTheme.body1.copyWith(
                      color: Theme.of(context).textTheme.caption.color))
            ],
          ),
          subtitle: Text(_dataParser(value)),
          contentPadding: EdgeInsets.all(0.0),
        );
      },
    ),
    StreamBuilder<List<int>>(
      stream: writeCharacteristic.value,
      initialData: writeCharacteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Characteristic'),
              Text(
                  '0x${writeCharacteristic.uuid.toString()}',
                  style: Theme.of(context).textTheme.body1.copyWith(
                    color: Theme.of(context).textTheme.caption.color))
              ],
            ),
            subtitle: Text(_dataParser(value)),
            contentPadding: EdgeInsets.all(0.0),
          );
        },
      ),


    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
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
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Start'),
              onPressed: () {startSession();},
            ),
            new RaisedButton(
              child: new Text('Stop'),
              onPressed: () {endSession();},
            ),
            new RaisedButton(
              child: new Text('Pump Up'),
              onPressed: () {
                changePumpPower('u');
              },
            ),
            new RaisedButton(
              child: new Text('Pump down'),
              onPressed: () {
                changePumpPower('d');
                downPressed = true;
              },
            ),
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${widget.device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => widget.device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                final state = snapshot.data;
                print(state);
                if(snapshot.hasData) {
                  return Column(
                    children: _buildServiceTiles(snapshot.data),
                  );
//                  return Column();
                }
                else {
                  print('not connected');
                  return Column();
                }

              },
            ),
          ],
        ),
      ),
    );
  }
}


//class BLEPage extends StatefulWidget {
//  @override
//  _BLEPage createState() => new _BLEPage();
//}
//
//class _BLEPage extends State<BLEPage> {
//  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
//  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
//  final String TARGET_DEVICE_NAME = "Bluefruit52";
//  String data = "";
//  Stream<List<int>> stream;
//
//  FlutterBlue flutterBlue = FlutterBlue.instance;
//  StreamSubscription<ScanResult> scanSubScription;
//
//  BluetoothDevice targetDevice;
//  BluetoothCharacteristic targetCharacteristic;
//
//  String connectionText = "";
//
//  @override
//  void initState() {
//    super.initState();
//    startScan();
//  }
//
//  startScan() {
//    setState(() {
//      connectionText = "Start Scanning";
//    });
//
//    scanSubScription = flutterBlue.scan().listen((scanResult) {
//      if (scanResult.device.name == TARGET_DEVICE_NAME) {
//        print('DEVICE found');
//        stopScan();
//        setState(() {
//          connectionText = "Found Target Device";
//        });
//
//        targetDevice = scanResult.device;
//        connectToDevice();
//      }
//    }, onDone: () => stopScan());
//  }
//
//  stopScan() {
//    scanSubScription?.cancel();
//    scanSubScription = null;
//  }
//
//  connectToDevice() async {
//    if (targetDevice == null) return;
//
//    setState(() {
//      connectionText = "Device Connecting";
//    });
//
//    await targetDevice.connect();
//    print('DEVICE CONNECTED');
//    setState(() {
//      connectionText = "Device Connected";
//    });
//
//    discoverServices();
//  }
//
//  disconnectFromDevice() {
//    if (targetDevice == null) return;
//
//    targetDevice.disconnect();
//
//    setState(() {
//      connectionText = "Device Disconnected";
//    });
//  }
//
//  discoverServices() async {
//    if (targetDevice == null) return;
//
//    List<BluetoothService> services = await targetDevice.discoverServices();
//    services.forEach((service) {
//      // do something with service
//      if (service.uuid.toString() == SERVICE_UUID) {
//        service.characteristics.forEach((characteristic) {
//          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
//            targetCharacteristic = characteristic;
//            writeData("Hi there, Dana");
//            stream = characteristic.value;
//            setState(() {
//              connectionText = "All Ready with ${targetDevice.name}";
//            });
//          }
//        });
//      }
//    });
//  }
//
//  writeData(String data) {
//    if (targetCharacteristic == null) return;
//
//    List<int> bytes = utf8.encode(data);
//    targetCharacteristic.write(bytes);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(connectionText),
//      ),
//
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          // Add your onPressed code here!
//          data = "works";
//          print(data);
//          writeData(data);
//        },
//        child: Icon(Icons.navigation),
//        backgroundColor: Colors.green,
//      ),
//
//      body: Center(
//        child: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Text('read', style: TextStyle(fontSize: 40.0)),
//              Padding(padding: EdgeInsets.all(10.0)),
//            ],
//          ),
//      ),
//    ));
//  }
//}
