import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import './helpers/ProductionDataPoint.dart';
import './helpers/numberpicker.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

class MyAda extends StatefulWidget {
  @override
  _MyAda createState() => new _MyAda();
}

class _MyAda extends State<MyAda> {
//  final databaseReference = Firestore.instance;
  List<ProductionDataPoint> sessionTimeSeries; //Timeseries for the current pumping session
  int _duration = 20;

  @override
  void initState() {
    super.initState();
    sessionTimeSeries = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(context),
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
//          new Text("Current number: $_duration"), // debug
          SizedBox(height: 20),
          SessionScreen(),
        ]
      ),

    );
  }

  Widget titleSection(BuildContext context){
    return Container(
      padding: const EdgeInsets.only(left: 45, right: 45, top: 60, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Ready to get started?',
              style: Theme.of(context).textTheme.display3,
            ),
            SizedBox(height: 12),
            Text(
              '2.5h since you last pumped',
              style: Theme.of(context).textTheme.body1,
            ),
        ],
      ),
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
  @override
  _SessionScreen createState() => _SessionScreen();
}

class _SessionScreen extends State<SessionScreen> with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;
  AnimationController percentageAnimationController;
  @override
  void initState() {
    super.initState();
    setState(() {
      percentage = 0.0;
    });
    percentageAnimationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 1000)
    )
      ..addListener((){
        setState(() {
          percentage = lerpDouble(percentage,newPercentage,percentageAnimationController.value);
        });
      });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return new Center(
      child: Container(
        height: 150.0,
        width: 150.0,
        child: new CustomPaint(
          foregroundPainter: new MyPainter(
              lineColor: themeData.accentColor,
              completeColor: themeData.primaryColor,
              completePercent: percentage,
              width: 8.0
          ),
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
                onPressed: (){
                  setState(() {
                    percentage = newPercentage;
                    newPercentage += 10;
                    if(newPercentage>100.0){
                      percentage=0.0;
                      newPercentage=0.0;
                    }
                    percentageAnimationController.forward(from: 0.0);
                  });
                }),
          ),
        ),
      )
    );
  }
}
