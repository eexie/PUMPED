import 'package:flutter/material.dart';
import './helpers/foundation.dart';
import 'package:flutter/cupertino.dart';
import './MainPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  final Color appPrimaryColor = new Color(0xFF1098A0);
  final Color appAccentColor = new Color(0x5FDCEEEE);
  final Color appBackgroundColor = Colors.white;
  final Color appErrorColor = new Color(0xFFFF0C3E);


  @override
  Widget build(BuildContext context) {
    if (isIos) {
      return CupertinoApp(
          theme: CupertinoThemeData(
              barBackgroundColor: CupertinoColors.extraLightBackgroundGray,
              primaryColor: CupertinoColors.destructiveRed),
          home: MainPage()
      );
    } else {
      return MaterialApp(
          title: 'Ada - The better, smart pump',
          theme: ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: appPrimaryColor,
            accentColor: appAccentColor,
            backgroundColor: appBackgroundColor,
            buttonColor: appPrimaryColor,
            cardColor: appBackgroundColor,
            textSelectionColor: appPrimaryColor,
            errorColor: appErrorColor,

            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            fontFamily: 'Rubik',
            textTheme: TextTheme(
              display4: TextStyle(fontFamily: 'Rufina', fontSize: 60.0),
              display3: TextStyle(fontFamily: 'Rufina', fontSize: 22.0),
              display2: TextStyle(fontFamily: 'Rufina', fontSize: 16.0),
              display1: TextStyle(fontFamily: 'Rufina', fontSize: 18.0, fontWeight: FontWeight.bold),
              title: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              body2: TextStyle(fontFamily: 'Rufina', fontSize: 18.0, fontWeight: FontWeight.normal),
              body1: TextStyle(fontSize: 12.0, color: Colors.grey[900]),
              button: TextStyle(fontSize: 14.0),
              caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
              subhead: TextStyle(fontSize: 10.0),
            ),
            iconTheme: IconThemeData(color: Colors.grey[600]),
          ),
//          localizationsDelegates: [
//            GlobalMaterialLocalizations.delegate,
//            GlobalWidgetsLocalizations.delegate,
//            FFULocalizations.delegate,
//          ],
//          supportedLocales: [
//            const Locale('fr', 'FR'),
//            const Locale('en', 'US'),
//          ]
          home: MainPage(),
          debugShowCheckedModeBanner: false,


      );
    }
  }
}


