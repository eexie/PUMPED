import 'package:flutter/material.dart';
import './helpers/ProductionDataPoint.dart';
import './helpers/numberpicker.dart';
import 'helpers/widgets.dart';
import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import './SessionScreen.dart';

class MyAda extends StatefulWidget {
  @override
  _MyAda createState() => new _MyAda();
}

class _MyAda extends State<MyAda> {
//  final databaseReference = Firestore.instance;
  List<ProductionDataPoint> sessionTimeSeries; //Timeseries for the current pumping session
  int _duration = 20;

  final String TARGET_DEVICE_NAME = "ADA";
  String data = "";
  Stream<List<int>> stream;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  @override
  void initState() {
    startScan();
    super.initState();
  }
  startScan() {
    print('scanning');
    setState(() {
      connectionText = "Connecting to device...";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      print(scanResult.device.name);
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();

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

//    setState(() {
//      connectionText = "Device Connecting";
//    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Ada is connected...";
    });

  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device disconnected...";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              TitleSection(
                titleText: 'Ready to get started?',
                subText: connectionText + '2.5h since you last pumped',
              ),
              Center(
                child: Container(
                  child: NumberPicker.integer(
                      initialValue: _duration,
                      minValue: 5,
                      maxValue: 35,
                      onChanged: (newDuration) =>
                          setState(() => _duration = newDuration)),
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 1))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => Center(
//                    title: Text(d.name),
//                    subtitle: Text(d.id.toString()),
                    child: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data ==
                            BluetoothDeviceState.connected) {
                          return new Center(
                              child: Container(
                                height: 150.0,
                                width: 150.0,
                                child: new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new RaisedButton(
                                    color: Theme.of(context).primaryColor,
                                    splashColor: Colors.blueAccent,
                                    shape: new CircleBorder(),
                                    child: new Text(
                                      'LET\'S GO!',
                                      style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                                    ),
                                    onPressed: () { Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SessionScreen(setDuration: _duration * 60, device: d)));
                                    },
                                  ),
                                ),
                              )
                          );
                        }
                        return new Center(
                            child: Container(
                              height: 150.0,
                              width: 150.0,
                              child: new Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: new RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  shape: new CircleBorder(),
                                  child: new Text(
                                    'Connecting to your Ada...',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                            )
                        );
                      },
                    ),
                  ))
                      .toList(),
                ),
              )
            ]
        ),
      ),
    );
  }


  Widget startButton(BuildContext context, String text) {
    ThemeData themeData = Theme.of(context);
    return new Center(
      child: Container(
        height: 150.0,
        width: 150.0,
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RaisedButton(
            color: Theme.of(context).primaryColor,
            splashColor: Colors.blueAccent,
            shape: new CircleBorder(),
            child: new Text(
              'LET\'S GO!',
              style: themeData.textTheme.button.copyWith(color: Colors.white),
            ),
            onPressed: () {Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                  SessionScreen(setDuration: _duration * 60)));
            },
          ),
        ),
      )
    );
  }
}

