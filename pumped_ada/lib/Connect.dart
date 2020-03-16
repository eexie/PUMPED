import 'package:flutter/material.dart';
import 'helpers/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key key}) : super(key: key);

  @override
  _ConnectScreen createState() => _ConnectScreen();
}
class _ConnectScreen extends State<ConnectScreen>{
  final databaseReference = Firestore.instance;
  ProgressDialog pr;
  String detectionType = "";
  DateTime detectionTime;

//  @override
//  void initState(){
//    getAnomalies('01-14-2020', '18-0');
//    super.initState();
//  }
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
    Future<String> getAnomalies(String date, String time) async{
      final userDocumentReference = databaseReference.collection("users")
          .document("emma");
      final sessionDocumentReference = userDocumentReference.collection(date).document(time);
      String anomalyType;
      await sessionDocumentReference.get().then((val) {
        anomalyType = val.data['anomaly'];
      });
      return anomalyType;
    }
    String anomaly;
    getAnomalies('01-14-2020', '18-0').then((value) {
      print(value);
      anomaly = value;
    });

    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            TitleSection(
              titleText: 'We\'re here for you',
              subText: 'Connect with an Ada expert and your community',
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      HealthMonitoringModule(
                        detectionTime: 'In January',
                        detectionType: 'long letdown times',
                        sessionDateTime: 'January 2, 6:00PM',
                        onPressedCallback: () {
//                          pr.show();
                          Future.delayed(Duration(seconds: 3)).then((value) {
//                            pr.hide().whenComplete(() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => CallExpertScreen()));
//                            }
//                            );
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Image.asset('assets/connect.png',
                          width: 316, height: 414, fit: BoxFit.contain),
                    ])),
          ],
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

