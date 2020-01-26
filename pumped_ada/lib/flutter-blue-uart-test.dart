//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:flutter_blue/flutter_blue.dart';
//
//class Chat extends StatefulWidget{
//  const Chat({Key key}) : super(key: key);
//
//  @override
//  _Chat createState() => new _Chat();
//}
//
//class _Chat extends State<Chat>{
//  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
//  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
//  final String TARGET_DEVICE_NAME = "Bluefruit52";
//
//  StreamSubscription <ScanResult> scanSubscription;
//  StreamSubscription stateSubscription;
//  StreamSubscription dataSubscription;
//  String connectionText = "";
//  var serial;
//  // Get instance
//  FlutterBlue provider = FlutterBlue.instance;
//
//  @override
//  void initState() {
//    super.initState();
//    startScan();
//  }
//
//  startScan(){
//    setState(() {
//      connectionText = "Start Scanning";
//    });
//
//    scanSubscription = provider
//        .scan()
//        .listen(_onDeviceFound, onDone: () => stopScan(), cancelOnError: true);
//
//  }
//  stopScan() {
//    scanSubscription?.cancel();
//    scanSubscription = null;
//  }
//
//  void _onDeviceFound(ScanResult result){
//    if(result.device.name == TARGET_DEVICE_NAME) {
//      print('DEVICE found');
//      stopScan();
//      setState(() {
//        connectionText = "Found Target Device";
//      });
//    }
//    serial = provider.init(result.device);
//
//    // Listen for connection state changes
//    stateSubscription = serial.onStateChange.listen(_updateConnectionState);
//    dataSubscription = serial.onTextReceived.listen(_receive);
//
//    // Connect to device
//    serial.connect();
//  }
//  void _updateConnectionState(SerialConnectionState state) {
//    // TODO: Update UI to show current connection state
//    debugPrint('SerialConnectionState: ${state.toString()}');
//  }
//
//  void _receive(String text) {
//    // TODO: Handle incoming data
//    debugPrint('IN: ${text}');
//  }
//
//  writeData(){
//    // Send data
//    serial.sendText('Hello BLE device!');
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(connectionText),
//      ),
//      body: new ChatScreen()
//    );
//  }
//
//}
//
//class ChatScreen extends StatefulWidget {
//
//  @override
//  State createState() => new ChatScreenState();
//}
//
//class ChatScreenState extends State<ChatScreen> {
//
//  final TextEditingController _chatController = new TextEditingController();
//  final List<ChatMessage> _messages = <ChatMessage>[];
//
//  void _handleSubmit(String text) {
//    _chatController.clear();
//    ChatMessage message = new ChatMessage(
//        text: text
//    );
//    setState(() {
//      _messages.insert(0, message);
//    });
//
//  }
//
//  Widget _chatEnvironment (){
//    return IconTheme(
//      data: new IconThemeData(color: Colors.blue),
//      child: new Container(
//        margin: const EdgeInsets.symmetric(horizontal:8.0),
//        child: new Row(
//          children: <Widget>[
//            new Flexible(
//              child: new TextField(
//                decoration: new InputDecoration.collapsed(hintText: "Starts typing ..."),
//                controller: _chatController,
//                onSubmitted: _handleSubmit,
//              ),
//            ),
//            new Container(
//              margin: const EdgeInsets.symmetric(horizontal: 4.0),
//              child: new IconButton(
//                icon: new Icon(Icons.send),
//
//                onPressed: ()=> _handleSubmit(_chatController.text),
//
//              ),
//            )
//          ],
//        ),
//
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Column(
//      children: <Widget>[
//        new Flexible(
//          child: ListView.builder(
//            padding: new EdgeInsets.all(8.0),
//            reverse: true,
//            itemBuilder: (_, int index) => _messages[index],
//            itemCount: _messages.length,
//          ),
//        ),
//        new Divider(
//          height: 1.0,
//        ),
//        new Container(decoration: new BoxDecoration(
//          color: Theme.of(context).cardColor,
//        ),
//          child: _chatEnvironment(),)
//      ],
//    );
//  }
//}
//const String _name = "bluefruit";
//
//class ChatMessage extends StatelessWidget {
//  final String text;
//
//// constructor to get text from textfield
//  ChatMessage({
//    this.text
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return new Container(
//        margin: const EdgeInsets.symmetric(vertical: 10.0),
//        child: new Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            new Container(
//              margin: const EdgeInsets.only(right: 16.0),
//              child: new CircleAvatar(
//                child: new Image.network("http://res.cloudinary.com/kennyy/image/upload/v1531317427/avatar_z1rc6f.png"),
//              ),
//            ),
//            new Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                new Text(_name, style: Theme.of(context).textTheme.subhead),
//                new Container(
//                  margin: const EdgeInsets.only(top: 5.0),
//                  child: new Text(text),
//
//                )
//              ],
//            )
//          ],
//        )
//    );
//  }
//}