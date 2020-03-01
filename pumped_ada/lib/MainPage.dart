import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//import './BLEPage.dart';
import './MyAda.dart';
import './PlaceHolderWidget.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
//import 'package:firebase_ui/l10n/localization.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';

//import './LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {

//  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;
  FirebaseUser _currentUser;

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
//  FirebaseUser user = _currentUser,
  List<Widget> tabs = [
//    BLEPage(),
//    PlaceholderWidget(Colors.green),
    SessionEndScreen(),
    MyAda(),
    PlaceholderWidget(Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return new SignInScreen(
        title: "Ada by PUMPED",
        header: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Text("Demo"),
          ),
        ),
        showBar: true,
        horizontalPadding: 8,
        bottomPadding: 5,
        avoidBottomInset: true,
        color: Color(0xFF363636),
        providers: [
          ProvidersTypes.google,
          ProvidersTypes.email,
        ],
      );
    } else {
      return Scaffold(
//      appBar: AppBar(
//        title: const Text('Ada'),
//      ),
        body: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return tabs[_currentIndex];
              }
              return BluetoothOffScreen(state: state);
            }),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          // this will be set when a new tab is tapped
//        currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('HOME'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.panorama_fish_eye),
              title: new Text('MY ADA'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text('CONNECT'),
            )
          ],
        ),
      );
    }
  }

  void _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);

    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

}
//class SignInScreen extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold();
//  }
//}