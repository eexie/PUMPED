import 'package:flutter/material.dart';
import './helpers/ProductionDataPoint.dart';
import './helpers/numberpicker.dart';
import 'dart:ui';
import 'dart:math';
import 'helpers/widgets.dart';
import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          Center(
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
          ),
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
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

class MyPainter extends CustomPainter{
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter({this.lineColor,this.completeColor,this.completePercent,this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center  = new Offset(size.width/2, size.height/2);
    double radius  = size.width/2;
    canvas.drawCircle(
        center,
        radius,
        line
    );
    double arcAngle = 2*pi* (completePercent/100);
    canvas.drawArc(
        new Rect.fromCircle(center: center,radius: radius),
        -pi/2,
        arcAngle,
        false,
        complete
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//paint background shapes

//class CurvePainter extends CustomPainter {
//  const CurvePainter({this.context});
//  final BuildContext context;
//  @override
//  void paint(Canvas canvas, Size size) {
//    var paint = Paint();
//    paint.color = Theme.of(context).accentColor;
//    paint.style = PaintingStyle.fill; // Change this to fill
//
//    var path = Path();
//
//    path.moveTo(0, size.height * 0.25);
//    path.quadraticBezierTo(
//        size.width / 2, size.height / 2, size.width, size.height * 0.25);
//    path.lineTo(size.width, 0);
//    path.lineTo(0, 0);
//
//    canvas.drawPath(path, paint);
//  }
//
//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) {
//    return true;
//  }
//}

class SessionScreen extends StatefulWidget{
  const SessionScreen({Key key, this.setDuration, this.device}) : super(key: key);

  final int setDuration;
  final BluetoothDevice device;

  @override
  _SessionScreen createState() => _SessionScreen();
}

class _SessionScreen extends State<SessionScreen> with TickerProviderStateMixin {
  AnimationController percentageAnimationController;
  String _letdownText = 'expressing...';

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
  DateTime targetEndTime;
  DateTime startTime;
  DateTime endTime;
  int sessionNumber = 0;
  List<String> mood = [];
  CollectionReference sessionCollection;
  DocumentReference newSession;
  DocumentReference sessionControlsReference;

  BluetoothCharacteristic writeCharacteristic;

  String get timerString {
    Duration duration = percentageAnimationController.duration * percentageAnimationController.value;
    if(duration.inSeconds <= 0){
      endSession();
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    startSession();
    print(widget.setDuration);
    percentageAnimationController = new AnimationController(
        vsync: this,
        duration: new Duration(seconds: widget.setDuration));
    percentageAnimationController.reverse(
        from: percentageAnimationController.value == 0.0
            ? 1.0
            : percentageAnimationController.value);
  }
  startSession() async {
    writeData('s 5');
    sessionTimeSeries.clear();
    print('start');
    await widget.device.discoverServices();
    startTime = new DateTime.now();
    getSessionControls();
    targetEndTime = DateTime.now().add(Duration(seconds: widget.setDuration));
    print(targetEndTime.toIso8601String());
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
      vacuumLvl = int.parse(value.substring(1));
      print('current vacuum level ${vacuumLvl}');
    }
    else if (value[0] == 'e'){ // pumping session ended
      createSessionRecord();
      print('end session, write to firebase');
//      Navigator.pushReplacement(
//          context,
//        MaterialPageRoute(
//          builder: (context) => SessionEndScreen())
//      );
      print('go to session summary screen');
    }
    else if(double.tryParse(value[0]) != null){ // received data point
      print('volume received '+ value);
      var timeStamp = value[0];
      var time = startTime.add(new Duration(seconds: int.parse(timeStamp)));
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to end this session'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {Navigator.of(context).pop(true); print('yes'); endSession();},
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                child: BackButton(
                  color: themeData.disabledColor,
                  onPressed: () =>
                    Navigator.of(context).pop(true),
                ),
              ),

              TitleSection(
                  titleText: 'You\'re doing great',
                  subText: 'Almost at letdown...'
              ),
              SizedBox(height: 30),
              Column(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150.0,
                    width: 150.0,

                    child: Center(
                      child: Expanded(
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: AnimatedBuilder(
                                      animation: percentageAnimationController,
                                      builder: (BuildContext context, Widget child) {
                                        return CustomPaint(
                                          painter: TimerPainter(
                                              animation: percentageAnimationController,
                                              backgroundColor: Colors.white,
                                              color: themeData.primaryColor),
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        AnimatedBuilder(
                                            animation: percentageAnimationController,
                                            builder: (_, Widget child) {
                                              return Text(
                                                timerString,
                                                style: themeData.textTheme.title,
                                              );
                                            }),
                                        Text(
                                          _letdownText,
                                          style: themeData.textTheme.caption,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                    child: new Text('Stop'),
                    onPressed: () {endSession();},
                  ),
                  Row(
//                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RaisedButton(
                        child: new Text('Pump down'),
                        onPressed: () {
                          changePumpPower('d');
                          downPressed = true;
                        },
                      ),
                      RaisedButton(
                        child: new Text('Pump Up'),
                        onPressed: () {
                          changePumpPower('u');
                        },
                      ),
                    ],
                  ),
                  StreamBuilder<List<BluetoothService>>(
                    stream: widget.device.services,
                    initialData: [],
                    builder: (c, snapshot) {
                      if(snapshot.hasData) {
                        return Column(
                          children: _buildServiceTiles(snapshot.data),
                        );
                      }
                      else {
                        print('not connected');
                        return Column();
                      }

                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionEndScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('End Session Page'),
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Great Session!',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            MyAda()));
              },
//              onPressed: () {},
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('back'),
            ) ,
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  TimerPainter({this.animation, this.backgroundColor, this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

