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

  List<ProductionDataPoint> sessionTimeSeries = []; //Timeseries for the current _blocing session
  bool inLetdown = true;
  int letdownLength = 0;

  // session controls
  int vacuumLvl = 0;
  int maxVacuumLvl = 0;
  bool downPressed = false;

  // session record data
  List<int> vacuumPowerLvls = [0];
  DateTime targetEndTime;
  DateTime startTime;
  DateTime endTime;
  int sessionNumber = 0;
  int totalVol;
  List<String> mood = [];
  int sessionLength;
  CollectionReference sessionCollection;
  DocumentReference newSession;
  DocumentReference sessionControlsReference;

  BluetoothCharacteristic writeCharacteristic;
  BluetoothCharacteristic readCharacteristic;

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
  void initState(){
    super.initState();
    getSessionControls();
    percentageAnimationController = new AnimationController(
        vsync: this,
        duration: new Duration(seconds: widget.setDuration));
    percentageAnimationController.reverse(
        from: percentageAnimationController.value == 0.0
            ? 1.0
            : percentageAnimationController.value);
    Future.delayed(Duration.zero, () {});
  }

  @override
  void dispose() {
    percentageAnimationController.dispose();
    super.dispose();
  }
  startSession() async {
    print('start');
    List<BluetoothService> targetServices = [];
    List<BluetoothCharacteristic> targetCharacteristics = [];
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        targetServices.add(service);
        targetCharacteristics = targetServices[0].characteristics;
      }

    });
    readCharacteristic = targetCharacteristics[0];
    readCharacteristic.setNotifyValue(true);

    writeCharacteristic = targetCharacteristics[1];
    print(writeCharacteristic.toString());

    String vacuumLvlToSend = vacuumLvl<10 ? '0' + vacuumLvl.toString() : vacuumLvl.toString();
    Future.delayed(Duration.zero, () {
      writeData('s' + vacuumLvlToSend);
    });

    targetEndTime = DateTime.now().add(Duration(seconds: widget.setDuration));
  }
  void rampUpVacuum() {
    print('ramp up by ${maxVacuumLvl-vacuumLvl} lvls');
    for(int i = 0; i < maxVacuumLvl-vacuumLvl; i++){
      Future.delayed(Duration(seconds: 5), () {
        changePumpPower('u');
      });
    }
  }
  void getSessionControls() async {
    sessionTimeSeries.clear();
    startTime = new DateTime.now();
//    getSessionControls();
    print('get controls');
    final userDocumentReference = databaseReference.collection("users").document("emily");
    String collectionTitle = startTime.month.toString()
        + '-' + startTime.day.toString()
        + '-' + startTime.year.toString(); //creates a collection of sessions for the day, if it doesn't exist
    sessionCollection = userDocumentReference.collection(collectionTitle);
    String documentTitle = startTime.hour.toString() + '-' + startTime.minute.toString();
    newSession = sessionCollection.document(documentTitle);

    CollectionReference personalizationCollection = userDocumentReference.collection('personalization');
    sessionControlsReference = personalizationCollection.document('sessionControls');

    //get count of # of sessions in collection
    await sessionCollection.getDocuments().then((value) {
      sessionNumber = value.documents.length + 1;
    });
    //get last session data to determine current session's controls
    await sessionControlsReference.get().then((value){
      setState(() {
        vacuumLvl = value.data['vacuumLvl'];
      });
      maxVacuumLvl = value.data['maxVacuumLvl'];
    });
    print('vacuumLvl' + vacuumLvl.toString() + ' maxVacuumLvl' + maxVacuumLvl.toString());
//    startSession();
    //discover services
    print('discover serviecs');
    List<BluetoothService> targetServices = [];
    List<BluetoothCharacteristic> targetCharacteristics = [];
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        targetServices.add(service);
        targetCharacteristics = targetServices[0].characteristics;
      }

    });
    readCharacteristic = targetCharacteristics[0];
    readCharacteristic.setNotifyValue(true);

    writeCharacteristic = targetCharacteristics[1];
    print(writeCharacteristic.toString());

    String vacuumLvlToSend = vacuumLvl<10 ? '0' + vacuumLvl.toString() : vacuumLvl.toString();
    Future.delayed(Duration.zero, () {
      writeData('s' + vacuumLvlToSend);
    });

    targetEndTime = DateTime.now().add(Duration(seconds: widget.setDuration));

    ////
//    final userDocumentReference = databaseReference.collection("users").document("emily");
//    String collectionTitle = startTime.month.toString()
//        + '-' + startTime.day.toString()
//        + '-' + startTime.year.toString(); //creates a collection of sessions for the day, if it doesn't exist
//    sessionCollection = userDocumentReference.collection(collectionTitle);
//    String documentTitle = startTime.hour.toString() + '-' + startTime.minute.toString();
//    newSession = sessionCollection.document(documentTitle);
//
//    CollectionReference personalizationCollection = userDocumentReference.collection('personalization');
//    sessionControlsReference = personalizationCollection.document('sessionControls');
//
//    //get count of # of sessions in collection
//    await sessionCollection.getDocuments().then((value) {
//      sessionNumber = value.documents.length + 1;
//    });
//    //get last session data to determine current session's controls
//    await sessionControlsReference.get().then((value){
//      setState(() {
//        vacuumLvl = value.data['vacuumLvl'];
//      });
//      maxVacuumLvl = value.data['maxVacuumLvl'];
//    });
//    print('vacuumLvl' + vacuumLvl.toString() + ' maxVacuumLvl' + maxVacuumLvl.toString());
////    startSession();
//    List<BluetoothService> targetServices = [];
//    List<BluetoothCharacteristic> targetCharacteristics = [];
//    List<BluetoothService> services = await widget.device.discoverServices();
//    services.forEach((service) {
//      if (service.uuid.toString() == SERVICE_UUID) {
//        targetServices.add(service);
//        targetCharacteristics = targetServices[0].characteristics;
//      }
//
//    });
//    readCharacteristic = targetCharacteristics[0];
//    readCharacteristic.setNotifyValue(true);
//
//    writeCharacteristic = targetCharacteristics[1];
//    print(writeCharacteristic.toString());
//
//    String vacuumLvlToSend = vacuumLvl<10 ? '0' + vacuumLvl.toString() : vacuumLvl.toString();
//    Future.delayed(Duration.zero, () {
//      writeData('s' + vacuumLvlToSend);
//    });
//
//    targetEndTime = DateTime.now().add(Duration(seconds: widget.setDuration));
  }
  void createSessionRecord() async {
    print('creating record');
    DateTime endTime = DateTime.now();

    String timeOfDay = getTimeOfDay(endTime);
    sessionLength = endTime.difference(startTime).inSeconds;
    totalVol = sessionTimeSeries.isEmpty ? 0 : sessionTimeSeries.last.volume;
    SessionData sessionRecord = new SessionData(
      sessionTimeSeries,
      letdownLength,
      vacuumPowerLvls.toSet().toList(),
      sessionLength,
      timeOfDay,
      endTime,
      sessionNumber,
      mood,
      totalVol,
    );
    int sessionVacuumMaxLvl = vacuumPowerLvls.reduce(max);
    sessionVacuumMaxLvl = downPressed ? sessionVacuumMaxLvl -=2 : sessionVacuumMaxLvl;
    print(sessionVacuumMaxLvl);

    // write document first
    databaseReference.runTransaction((transaction) async{
//      sessionRecord.sessionNumber = sessionNumber;
      await transaction.set(newSession, sessionRecord.toMap());

      // if user was ok with a higher vacuum power setting this session, record it
      maxVacuumLvl = sessionVacuumMaxLvl > maxVacuumLvl? sessionVacuumMaxLvl : maxVacuumLvl;
      await transaction.set(sessionControlsReference, {'vacuumLvl': vacuumLvl, 'maxVacuumLvl': maxVacuumLvl});
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
      rampUpVacuum();
    }
    else if (value[0] == 'v') { // current vacuum level
      vacuumLvl = int.parse(value.substring(1));
      vacuumPowerLvls.add(vacuumLvl);
      print('current vacuum level ${vacuumLvl}');
    }
    else if (value[0] == 'e'){ // pumping session ended
      Future.delayed(Duration.zero, () {
        createSessionRecord();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SessionEndScreen(
                    totalVol: totalVol,
                    sessionLength: Duration(seconds: sessionLength)
                ))
        );
        print('end session, write to firebase');
        createSessionRecord();
      });
    }
    else if(int.tryParse(value[0])!=null){ // received data point
      print('volume received '+ value);
      var time = DateTime.now();
      var volume = int.parse(value[0]);
      volume = int.tryParse(value[1]) != null ? volume * 10 + int.parse(value[1]) : volume;
      ProductionDataPoint dataPoint = new ProductionDataPoint(time, volume);
      sessionTimeSeries.add(dataPoint);
    }
//    print(double.parse(value));
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
    writeData('v' + change);
//    writeData('v' + change);
    print("changed pump power " + change);
    vacuumLvl = (change == 'v') ? 1 + vacuumLvl : -1 + vacuumLvl;
    Future.delayed(Duration.zero, ()
    {
      print('vacuum lvl' + vacuumLvl.toString());
      setState(() {
        vacuumLvl = vacuumLvl;
      });
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
//                Text('Characteristic'),
//                Text(
//                    '0x${readCharacteristic.uuid.toString()}',
//                    style: Theme.of(context).textTheme.bodyText2.copyWith(
//                        color: Theme.of(context).textTheme.caption.color))
              ],
            ),
//            subtitle: Text(_dataParser(value)),
//            contentPadding: EdgeInsets.all(0.0),
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
//                Text('Characteristic'),
//                Text(
//                    '0x${writeCharacteristic.uuid.toString()}',
//                    style: Theme.of(context).textTheme.bodyText2.copyWith(
//                        color: Theme.of(context).textTheme.caption.color))
              ],
            ),
//            subtitle: Text(_dataParser(value)),
//            contentPadding: EdgeInsets.all(0.0),
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
    for(i; i < vacuumLvl/2; i++) {
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
              Future.delayed(Duration.zero, ()
              {
                setState(() {
                  vacuumLvl = vacuumLvl;
                });
              });
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
              Future.delayed(Duration.zero, ()
              {
                setState(() {
                  vacuumLvl = vacuumLvl;
                });
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
                  Text('POWER '+ vacuumLvl.toString(), style: themeData.textTheme.subtitle1),
                  pumpControls(),
                  RaisedButton(
                    child: new Text('STOP', style: themeData.textTheme.button.copyWith(color: Colors.white)),
                    onPressed: () {endSession();},
                  ),
                  StreamBuilder<List<BluetoothService>>(
                    stream: widget.device.services,
                    initialData: [],
                    builder: (c, snapshot) {
                      if(snapshot.hasData) {
                        return Column( //debug
                          children: _buildServiceTiles(snapshot.data),
                        );
                      }
                      else {
                        return Column();
                      }
//                      return Column();

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
  const SessionEndScreen({Key key, this.totalVol, this.sessionLength}) : super(key: key);
  final int totalVol;
  final Duration sessionLength;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TitleSection(
              titleText: 'Great Session!',
              subText: '',
            ),
            Center(
                child: Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: ShapeDecoration(
                    color: themeData.primaryColor,
                    shape: CircleBorder(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
//                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        totalVol.toString() + ' mL',
                        style: themeData.textTheme.headline6.copyWith(color: Colors.white),
                      ),
                      Text(
                        '${sessionLength.inMinutes}:${(sessionLength.inSeconds % 60)
                        .toString()
                        .padLeft(2, '0')}',
                        style: themeData.textTheme.bodyText2.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                )
            ),
            SizedBox(height: 20),
//            Container(
//              padding: const EdgeInsets.only(left: 38, right: 38),
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  Text(
//                      'How was this session?',
//                      style: themeData.textTheme.headline3
//                  ),
//                  SizedBox(
//                    height: 150.0,
//                    child: ListView(
//                        children:<Widget>[
//                          ListTile(
//                            leading: Icon(Icons.radio_button_unchecked),
//                            title: Text('Map'),
//                          ),
//                          ListTile(
//                            leading: Icon(Icons.radio_button_checked),
//                            title: Text('Album'),
//                          ),
//                          ListTile(
//                            leading: Icon(Icons.phone),
//                            title: Text('Phone'),
//                          ),
//                        ]
//                    ),
//                  ),
//                ],
//              ),
//            ),

//            FlatButton(
//              onPressed: () {
//                Future.delayed(Duration.zero, () {
//                  Navigator.of(context).pop(true);
//                });
//              },
////              color: Colors.blue,
////              textColor: Colors.white,
//              child: Text('EXIT'),
//            ) ,
          ],
        ),
      ),
    );
  }
}