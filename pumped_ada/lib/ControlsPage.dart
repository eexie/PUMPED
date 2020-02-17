import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import './helpers/ProductionDataPoint.dart';
import 'dart:io';

class ControlsPage extends StatefulWidget {
  @override
  _ControlsPage createState() => new _ControlsPage();
}

class _ControlsPage extends State<ControlsPage> {
//  final databaseReference = Firestore.instance;
  List<ProductionDataPoint> sessionTimeSeries; //Timeseries for the current pumping session


  @override
  void initState() {
    super.initState();
    sessionTimeSeries = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}