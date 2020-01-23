import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BLEPage extends StatefulWidget {
  @override
  _BLEPage createState() => new _BLEPage();
}

class _BLEPage extends State<BLEPage> {
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  final String TARGET_DEVICE_NAME = "Bluefruit52";
  String data = "";
  Stream<List<int>> stream;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  Widget _myService(List<BluetoothService> services) {

    services.forEach((service) {
      service.characteristics.forEach((character) {
        if (character.uuid.toString() == CHARACTERISTIC_UUID) {
          character.setNotifyValue(!character.isNotifying);
          stream = character.value;
        }
      });
    });
    return Container(
      child: StreamBuilder<List<int>>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasError) return Text('Error : ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.active) {
          var currentValue = _dataParser(snapshot.data);
          return new Center(
              child: Text(currentValue),
          );
        } else {
          return Text('Check the stream');
        }
      }),
    );
  }
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
            writeData("Hi there, Dana");
            stream = characteristic.value;
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

  readData() async {
    if (targetDevice == null) return;
    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service){
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) async {
          List<int> value = await characteristic.read();
          print(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          data = "works";
          print(data);
          writeData(data);
          readData();
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),

      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('read', style: TextStyle(fontSize: 40.0)),
              Padding(padding: EdgeInsets.all(10.0)),
              RaisedButton(
                child: Text(
                  "Press me",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                onPressed: () => readData(),
              )
              ],
            ),


//        child:  Text(data),
//        child: StreamBuilder<List<BluetoothCharacteristic>>(
//          stream: targetCharacteristic.value,
//          builder: (c, AsyncSnapshot<List<int>>snapshot) {
//            print(stream);
//            if (snapshot.hasError)
//              return Text('Error: ${snapshot.error}');
//
//            if (snapshot.connectionState == ConnectionState.active) {
//              var currentValue = _dataParser(snapshot.data);
//              return Center(
//                child: Text(currentValue),
//              );
//            } else {
//              return Text('Check the stream');
//            }
//          },
        ),
//        child: StreamBuilder<List<BluetoothService>>(
//          stream: targetDevice.services,
//          initialData: [],
//          builder: (c, snapshot) {
//            return _myService(snapshot.data);
//          },
//        ),
      ),
    );
  }
}
