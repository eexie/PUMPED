import 'package:flutter/material.dart';
import 'helpers/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ConnectScreen extends StatelessWidget{
  ProgressDialog pr;
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
        isDismissible: true
    );
    pr.style(
      message: 'Connecting you with an available expert...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)

    );
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            TitleSection(
              titleText: 'We\'re here for you',
              subText: 'Connect with an Ada expert and your community',
            ),
            SizedBox(height: 20),
            HealthMonitoringModule(
              detectionTime: 'Last week',
              detectionType: 'long letdown times',
              sessionDateTime: DateTime.now(),
              onPressedCallback: () {
                pr.show();
                Future.delayed(Duration(seconds: 3)).then((value) {
                  pr.hide().whenComplete(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => CallExpertScreen()));
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CallExpertScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            TitleSection(
              titleText: 'Welcome back',
              subText: 'home page subtext',
            ),
          ],
        ),
      ),
    );
  }
}

