import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './BLEPage.dart';
import './PlaceHolderWidget.dart';

//import './LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> tabs = [
    BLEPage(),
    PlaceholderWidget(Colors.deepOrange),
    PlaceholderWidget(Colors.green),
    PlaceholderWidget(Colors.blue)
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ada'),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
//        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home, color: Colors.grey[600]),
            title: new Text('Home', style: TextStyle(color: Colors.grey[600])),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.power_settings_new, color: Colors.grey[600]),
            title: new Text('Control', style: TextStyle(color: Colors.grey[600])),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.grey[600]),
            title: Text('Community', style: TextStyle(color: Colors.grey[600])),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.grey[600]),
            title: Text('Settings', style: TextStyle(color: Colors.grey[600]))
          )
        ],
      ),
    );
  }

}