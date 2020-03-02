import 'package:flutter/material.dart';
import './helpers/auth.dart';
import 'helpers/widgets.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            TitleSection(
              titleText: 'Welcome back',
              subText: 'home page subtext',
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () => authService.signOut(),
              color: Colors.red,
              textColor: Colors.white,
              child: Text('Signout'),
            ),
          ],
        ),
      ),
    );
  }
}