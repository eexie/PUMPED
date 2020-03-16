import 'package:flutter/material.dart';
import './helpers/auth.dart';
import 'helpers/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  HomeScreen(this.goToMyAda, this.goToConnect);
  final Function goToMyAda;
  final Function goToConnect;
  final databaseReference = Firestore.instance;
  List<Widget> sessionInfo = [];

  void getSessionData() async {
    sessionInfo.clear();

    final userDocumentReference = databaseReference.collection("users")
        .document("emma");
    final sessionCollectionReference = userDocumentReference.collection(
        "01-02-2020");
    List sessionsList = await sessionCollectionReference.getDocuments().then((
        val) => val.documents);

    for (int i = 0; i < min(sessionsList.length, 10); i++) {
      var doc = sessionCollectionReference.document(
          sessionsList[i].documentID.toString());
      await doc.get().then((val) {
        var volume = val.data['totalVol'];
        var hourMin = val.documentID;
        sessionInfo.add(sessionRow(hourMin, double_to_int(double.parse(volume))));
        print(sessionInfo.length);
      });
    }
  }
  int double_to_int(double vol){
    double multiplier = .5;
    return (multiplier * vol).round();
  }

  Widget sessionRow (String hourMin, int volume) {
    String month_date = '01/02';
    return Column(

        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month_date + ' ' + hourMin),
//            SizedBox(width: 30),
              Text(volume.toString() + 'mL'),
            ],
          ),
          SizedBox(height: 10),
//        Divider(),
        ]

    );
  }

  @override
  Widget build(BuildContext context) {
    getSessionData();
    ThemeData themeData = Theme.of(context);
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TitleSection(
                    titleText: 'Welcome Back, Ada!',
                  ),
//                  PopupMenuButton<Choice>(

//                  )

                ]
              )

//      Container(
//          padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
//          child: Expanded(
//              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//            Text('Welcome Back, Ada!',
//                style: themeData.textTheme.headline2.copyWith(
//                    color: themeData.textTheme.headline2.color)),
//            Container(
//              color: Colors.transparent,
//              height: 50,
//              width: 100,
//            ),
//            Image.asset('assets/profile_pic.png',
//                width: 46, height: 46, fit: BoxFit.cover),
//          ])))Container(
//                padding: const EdgeInsets.only(left: 20),,
              ,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HealthMonitoringModule(
                        detectionTime: 'Last week',
                        detectionType: 'long letdown times',
                        sessionDateTime: 'January 2, 6:00PM',
                        onPressedCallback: goToConnect,
//                        onPressedCallback: () {goToConnect; print('gotoconnect');},
                      ),
                      SizedBox(height: 20),
//                      Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RaisedButton(
                            child: new Text('START YOUR NEXT SESSION', style: themeData.textTheme.button.copyWith(color: Colors.white)),
                            onPressed: goToMyAda,
                          )
                        ]
                      ),

//                      Divider(),
                      SizedBox(height: 20),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended For You',
                              style: themeData.textTheme.headline3,
                            ),
                          ]
                      ),
                      SizedBox(height: 10),
                      Image.asset('assets/content_cards.png',
                          width: 316, height: 208, fit: BoxFit.contain),
                      SizedBox(height: 20),
                      MaterialButton(
                        onPressed: () => authService.signOut(),
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Signout'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            sessionInfo.insert(
                                0,
                                Text(
                                  'Your recent sessions',
                                  style: themeData.textTheme.headline2
                                )
                            );
                            sessionInfo.insert(
                              1,
                                Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('TIME', style: themeData.textTheme.bodyText1.copyWith(color: themeData.primaryColor)),
                                          Text('VOLUME', style: themeData.textTheme.bodyText1.copyWith(color: themeData.primaryColor)),
                                        ],
                                      ),

                                    ]
                                )
                            );
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SessionLogsPage(sessionInfo: sessionInfo)));
                          });

                        },
                        color: themeData.primaryColor,
                        textColor: Colors.white,
                        child: Text('Past session logs'),
                      ),
                      SizedBox(height: 30),
                    ]
                  )
              ),
            ]
        ));
  }

}

class SessionLogsPage extends StatefulWidget {
  const SessionLogsPage({Key key, this.sessionInfo}) : super(key: key);
  final List<Widget> sessionInfo;

  @override
  _SessionLogsPage createState() => _SessionLogsPage();
}
class _SessionLogsPage extends State<SessionLogsPage>{


  @override
//  void initState() {
//    sessionInfo.clear();
////    sessionInfo.add(
////      Text(
////        'Your recent sessions',
////        style: themeData.textTheme.headline3
////      )
////    );
////    getSessionData();
//    super.initState();
////    print(sessionInfo.length);
//  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 65),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.sessionInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
