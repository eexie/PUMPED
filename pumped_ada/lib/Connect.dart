import 'package:flutter/material.dart';
import 'helpers/widgets.dart';

class ConnectScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
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
                sessionDateTime: DateTime.now()
            ),
          ],
        ),
      ),
    );
  }
}