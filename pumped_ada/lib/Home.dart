import 'package:flutter/material.dart';
import 'package:pumped_ada/MainPage.dart';
import './helpers/auth.dart';
import 'helpers/widgets.dart';
import 'connect.dart';
import 'MyAda.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen(this.goToMyAda, this.goToConnect);
  final Function goToMyAda;
  final Function goToConnect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              TitleSection(
                titleText: 'Welcome Back, Ada!',
              ),
//      Container(
//          padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
//          child: Expanded(
//              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//            Text('Welcome Back, Ada!',
//                style: Theme.of(context).textTheme.headline2.copyWith(
//                    color: Theme.of(context).textTheme.headline2.color)),
//            Container(
//              color: Colors.transparent,
//              height: 50,
//              width: 100,
//            ),
//            Image.asset('assets/profile_pic.png',
//                width: 46, height: 46, fit: BoxFit.cover),
//          ])))Container(
//                padding: const EdgeInsets.only(left: 20),,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/milk_prod_graph.png',
                        height: 126, fit: BoxFit.contain
                      ),
                      HealthMonitoringModule(
                        detectionTime: 'Last week',
                        detectionType: 'long letdown times',
                        sessionDateTime: DateTime.now(),
                        onPressedCallback: goToConnect,
//                        onPressedCallback: () {goToConnect; print('gotoconnect');},
                      ),
                      SizedBox(height: 20),
//                      Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RaisedButton(
                            child: new Text('START YOUR NEXT SESSION', style: Theme.of(context).textTheme.button.copyWith(color: Colors.white)),
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
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ]
                      ),
                      SizedBox(height: 10),
                      Image.asset('assets/content_cards.png',
                          width: 316, height: 208, fit: BoxFit.contain),
                      SizedBox(height: 20),
                    ]
                  )
              ),
            ]
        ));
  }
}
