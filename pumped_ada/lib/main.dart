import 'package:flutter/material.dart';
import './helpers/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './MainPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
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
//          brightness: Brightness.light,
            primaryColor: Colors.teal[700],
            accentColor: Colors.teal,
            backgroundColor: Colors.grey[50],

            // Define the default font family.
//          fontFamily: 'Georgia',

            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
              headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
              body1: TextStyle(fontSize: 14.0, color: Colors.grey[900]),
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          home: MainPage()


      );
    }
  }
}

