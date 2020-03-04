import 'package:flutter/material.dart';
import './helpers/foundation.dart';
import 'package:flutter/cupertino.dart';
import './MainPage.dart';
import './helpers/auth.dart';

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
              headline1: TextStyle(fontFamily: 'Rufina', fontSize: 60.0),
              headline2: TextStyle(fontFamily: 'Rufina', fontSize: 22.0),
              headline3: TextStyle(fontFamily: 'Rufina', fontSize: 16.0),
              headline4: TextStyle(fontFamily: 'Rufina', fontSize: 18.0, fontWeight: FontWeight.bold),
              headline6: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              bodyText1: TextStyle(fontFamily: 'Rufina', fontSize: 14.0, fontWeight: FontWeight.normal),
              bodyText2: TextStyle(fontSize: 14.0, color: Colors.grey[900]),
              button: TextStyle(fontSize: 14.0),
              caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
              subtitle1: TextStyle(fontSize: 10.0),
            ),
            iconTheme: IconThemeData(color: Colors.grey[600]),
            appBarTheme: AppBarTheme(
              elevation: 0.0,
              color: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.grey[600],
              ),
              textTheme: TextTheme(headline6: TextStyle(fontSize: 16.0, color: Colors.grey[600])),
            ),
          ),

//          home: MainPage(),     EMILY: uncomment this  and comment the next 9 lines
          home: StreamBuilder(
            stream: authService.user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MainPage();
              } else {
                return SignInPage();
              }
            }),
          debugShowCheckedModeBanner: false,


      );
    }
  }
}


