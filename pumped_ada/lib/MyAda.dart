import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import './helpers/ProductionDataPoint.dart';
import './helpers/numberpicker.dart';
import 'dart:ui';
import 'dart:math';
import './widgets.dart';

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
          SizedBox(height: 50),
          TitleSection(
            titleText: 'Ready to get started?',
            subText: '2.5h since you last pumped',
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
//          new Text("Current number: $_duration"), // debug
          SizedBox(height: 20),
          startButton(context),
//          SessionScreen(),
        ]
      ),

    );
  }


  Widget startButton(BuildContext context) {
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
  const SessionScreen({Key key, this.setDuration}) : super(key: key);
  final int setDuration;
  @override
  _SessionScreen createState() => _SessionScreen();
}

class _SessionScreen extends State<SessionScreen> with TickerProviderStateMixin {
  DateTime targetEndTime = DateTime.now().add(new Duration(minutes: 1));
  DateTime startTime;
  AnimationController percentageAnimationController;
  String _letdownText = 'expressing...';

  String get timerString {
    Duration duration = percentageAnimationController.duration * percentageAnimationController.value;
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
  startSession() {
//    writeData('s 5');
//    sessionTimeSeries.clear();
    print('start');
    startTime = new DateTime.now();
    targetEndTime = DateTime.now().add(Duration(seconds: widget.setDuration));
    print(targetEndTime.toIso8601String());
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
            onPressed: () => Navigator.of(context).pop(true),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              child: BackButton(
                color: themeData.disabledColor,
                onPressed: () => _onWillPop(),
              ),
            ),

            TitleSection(
                titleText: 'You\'re doing great',
                subText: 'Almost at letdown...'
            ),
            SizedBox(height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 150.0,
                  width: 150.0,

                  child: Column(
                    children: <Widget>[
                      Expanded(
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
                    ],

                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        child: AnimatedBuilder(
                            animation: percentageAnimationController,
                            builder: (_, Widget child) {
                              return Icon(percentageAnimationController.isAnimating
                                  ? Icons.pause
                                  : Icons.play_arrow);
                            }),
                        onPressed: () {
                          if (percentageAnimationController.isAnimating) {
                            percentageAnimationController.stop();
                          } else {
                            percentageAnimationController.reverse(
                                from: percentageAnimationController.value == 0.0
                                    ? 1.0
                                    : percentageAnimationController.value);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
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
