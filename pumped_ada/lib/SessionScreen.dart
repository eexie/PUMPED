import 'package:flutter/material.dart';
import './helpers/ProductionDataPoint.dart';
import 'dart:ui';
import 'helpers/widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert' show utf8;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool inLetdown = true;
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
      });

      //get last session data to determine current session's controls
      await transaction.get(sessionControlsReference).then((value) {
        setState(() {
          vacuumLvl = value.data['vacuumPower'];
          letdownSpeed = value.data['letdownSpeed'];
          letdownVacuumLvl = value.data['letdownVacuum'];
        });
      });
    });
  }
  void createSessionRecord() async {
    print('creating record');
    DateTime endTime = DateTime.now();

    String timeOfDay = getTimeOfDay(endTime);
    int sessionLength = endTime.difference(startTime).inSeconds;

    SessionData sessionRecord = new SessionData(
      sessionTimeSeries,
      letdownLength,
      vacuumPowerLvls.toSet().toList(),
      sessionLength,
      timeOfDay,
      endTime,
      sessionNumber,
      mood,
      sessionTimeSeries.last.volume,
    );
    int sessionVacuumMaxLvl = vacuumPowerLvls.reduce(max);
    sessionVacuumMaxLvl = downPressed ? sessionVacuumMaxLvl -=2 : sessionVacuumMaxLvl;

    // write document first
    databaseReference.runTransaction((transaction) async{
      await transaction.set(newSession, sessionRecord.toMap());

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
      setState(() {
        inLetdown = true;
      });
      letdownLength = DateTime.now().difference(startTime).inSeconds;
      print('letdown detected');
    }
    else if (value[0] == 'v') { // current vacuum level
      vacuumLvl = int.parse(value.substring(1));
      vacuumPowerLvls.add(vacuumLvl);
      print('current vacuum level ${vacuumLvl}');
    }
    else if (value[0] == 'e'){ // pumping session ended
//      createSessionRecord();
      print('end session, write to firebase');
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SessionEndScreen())
        );
      });
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
    writeData('v ' + change);
    print("changed pump power " + change);
    print('vacuum lvl' + vacuumLvl.toString());
    setState(() {
      vacuumLvl = vacuumLvl;
    });
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
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
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
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
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
            onPressed: () {
              endSession();
//              Future.delayed(Duration(seconds: 1), () {});

//              writeData('e');
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  Widget _buildDot(bool active) {
    final shape = ShapeBorder.lerp(
      CircleBorder(),
      CircleBorder(),
      vacuumLvl.toDouble(),
    );
    final color = active? Colors.green : Colors.grey[100];
    final size = Size.fromRadius(4);
    return Container(
      width: size.width,
      height: size.height,
      margin: EdgeInsets.all(6.0),
      decoration: ShapeDecoration(
        color: color,
        shape: shape,
      ),
    );
  }
  Widget vacuumLvlDots(){
    List<Widget> dots = [];
    int i = 0;
    for(i; i < vacuumLvl; i++) {
      dots.add(_buildDot(true));
    }
    for(i; i<6; i++){
      dots.add(_buildDot(false));
    }

    return Row(
      children: dots,
    );
  }

  Widget pumpControls(){
    print('letdown ${inLetdown}');
    if(inLetdown) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton(
            shape: new CircleBorder(),
            color: Colors.grey[100],
            child: Icon(Icons.remove),
            onPressed: () {
              changePumpPower('d');
              downPressed = true;
            },
          ),
          vacuumLvlDots(),
          FlatButton(
            shape: new CircleBorder(),
            color: Colors.grey[100],
            child: Icon(Icons.add),
            onPressed: () {
              changePumpPower('u');
              print('vacuum lvl' + vacuumLvl.toString());
              setState(() {
                vacuumLvl = vacuumLvl;
              });
            },
          ),
        ],
      );
    } else return SizedBox(height: 20);
  }

  Widget circularProgressTimer(ThemeData themeData){
    return Container(
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
                                style: themeData.textTheme.headline6,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              TitleSection(
                  titleText: 'You\'re doing great',
                  subText: 'Almost at letdown...'
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  circularProgressTimer(themeData),
                  SizedBox(height: 20),
                  RaisedButton(
                    child: new Text('Stop'),
                    onPressed: () {endSession();},
                  ),
                  pumpControls(),
                  StreamBuilder<List<BluetoothService>>(  //debug
                    stream: widget.device.services,
                    initialData: [],
                    builder: (c, snapshot) {
                      if(snapshot.hasData) {
                        return Column(
                          children: _buildServiceTiles(snapshot.data),
                        );
                      }
                      else {
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
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Great Session!',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  .copyWith(color: Colors.grey[600]),
            ),
            MaterialButton(
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  Navigator.of(context).pop(true);
                });
              },
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