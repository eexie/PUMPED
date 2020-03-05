import 'package:flutter/material.dart';
import 'package:pumped_ada/MainPage.dart';
import './helpers/auth.dart';
import 'helpers/widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  void onContactBtnPushed() {
    print("change the gd page");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
          child: Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text('Welcome Back, Ada!',
                style: Theme.of(context).textTheme.headline2.copyWith(
                    color: Theme.of(context).textTheme.headline2.color)),
            Container(
              color: Colors.transparent,
              height: 50,
              width: 100,
            ),
            Image.asset('assets/profile_pic.png',
                width: 46, height: 46, fit: BoxFit.cover),
          ]))),
      Container(
          padding: const EdgeInsets.only(left: 25),
          child: Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Image.asset('assets/milk_prod_graph.png',
                width: 317, height: 136, fit: BoxFit.cover)
          ]))),
      Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(top: 20),
          child: Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FlatButton(
                onPressed: onContactBtnPushed,
                child: Image.asset('assets/contact_expert_home_btn.png',
                    width: 330, height: 70, fit: BoxFit.cover)),
          ]))),
      Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(top: 10),
          child: Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/one_more_reco.png',
                width: 330, height: 27, fit: BoxFit.cover),
          ]))),
      Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/divider.png',
              width: 330, height: 1, fit: BoxFit.cover)
    ])),
          Container(
              color: Colors.transparent,
           //   padding: const EdgeInsets.only(top: 20),
              child: Expanded(
                  child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    FlatButton(
                        onPressed: onContactBtnPushed,
                        child: Image.asset('assets/start_new_session_button.png',
                            width: 300, height: 36, fit: BoxFit.cover)),
                  ]))),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset('assets/divider.png',
                    width: 330, height: 1, fit: BoxFit.cover)
              ])),
          Container(
              padding: const EdgeInsets.only(left: 20),
              child: Expanded(
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text('Recommended For You',
                        style: Theme.of(context).textTheme.headline3.copyWith(
                            color: Theme.of(context).textTheme.headline3.color)),
                  ]))),
          Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, children: [
                Image.asset('assets/content_cards.png',
                    width: 316, height: 208, fit: BoxFit.cover)
              ])),
    ]));
  }
}
