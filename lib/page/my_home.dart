import 'package:dial_videocall/dial_make_videocall.dart';
import 'package:dial_videocall/dial_videocall.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MyHome extends StatefulWidget {
  final String firebaseToken;
  const MyHome({Key key, @required this.firebaseToken}) : super(key: key);
  @override
  _MyHomeState createState() => new _MyHomeState();
}

class _MyHomeState extends State<MyHome> with WidgetsBindingObserver {
  bool isOnCall;
  bool _isAccept;
  TextEditingController _textFirebaseTokenController;
  String sessionFrom;
  String sessionTo;

  String _callid;
  String _videoMinRecvBandwidth;
  String _videoMaxSendBandwidth;
  String _videoMaxRecvBandwidth;
  String _videoMinSendBandwidth;

  SharedPreferences prefs;

  static const platform = MethodChannel('flutter.native/powerOff');
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed");
      Future.delayed(const Duration(milliseconds: 1000), () {
        _asyncMethod();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      isOnCall = false;
      _isAccept = false;
    });
    _textFirebaseTokenController =
        TextEditingController(text: widget.firebaseToken);
    _asyncMethod();
  }

  void _asyncMethod() async {
    await _checkIncomingNotification();
    if (isSessionAvailable()) {
      _goToCallPage();
    }
  }

  bool isSessionAvailable() {
    return (sessionFrom != null &&
        sessionFrom.isNotEmpty &&
        sessionTo != null &&
        sessionTo.isNotEmpty);
  }

  Future<void> _checkIncomingNotification() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage?.data != null) {
      sessionFrom = await initialMessage.data['session_from'];
      sessionTo = await initialMessage.data['session_to'];

      _callid = await initialMessage.data['callid'];
      _videoMinRecvBandwidth =
          await initialMessage.data['videoMinRecvBandwidth'];
      _videoMaxSendBandwidth =
          await initialMessage.data['videoMaxSendBandwidth'];
      _videoMaxRecvBandwidth =
          await initialMessage.data['videoMaxRecvBandwidth'];
      _videoMinSendBandwidth =
          await initialMessage.data['videoMinSendBandwidth'];
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data != null) {
        sessionFrom = message.data['session_from'];
        sessionTo = message.data['session_to'];

        _callid = message.data['callid'];
        _videoMinRecvBandwidth = message.data['videoMinRecvBandwidth'];
        _videoMaxSendBandwidth = message.data['videoMaxSendBandwidth'];
        _videoMaxRecvBandwidth = message.data['videoMaxRecvBandwidth'];
        _videoMinSendBandwidth = message.data['videoMinSendBandwidth'];

        if (sessionFrom != null && sessionTo != null) {
          _goToCallPage();
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print("Handling a foreground callid : ${message.data['callid']}");
      DialVideoCall vcall = DialVideoCall(
        sessionFrom: message.data['session_from'],
        sessionTo: message.data['session_to'],
        isAnswer: null,
        isAccept: null,
        useName: true,
        useMuted: true,
        useSwitchCamera: true,
        callid: message.data['callid'],
        videoMinRecvBandwidth: message.data['videoMinRecvBandwidth'],
        videoMaxSendBandwidth: message.data['videoMaxSendBandwidth'],
        videoMaxRecvBandwidth: message.data['videoMaxRecvBandwidth'],
        videoMinSendBandwidth: message.data['videoMinSendBandwidth'],
      );
      await vcall
          .receivedNotification(message.data['session_to'])
          .then((value) {
        print("DARI CLIENT FIREBASE");
      });
      await print('Message data: ${message.data}');
      if (message.data != null) {
        sessionFrom = message.data['session_from'];
        sessionTo = message.data['session_to'];

        _callid = message.data['callid'];
        _videoMinRecvBandwidth = message.data['videoMinRecvBandwidth'];
        _videoMaxSendBandwidth = message.data['videoMaxSendBandwidth'];
        _videoMaxRecvBandwidth = message.data['videoMaxRecvBandwidth'];
        _videoMinSendBandwidth = message.data['videoMinSendBandwidth'];
        if (sessionFrom != null && sessionTo != null) {
          _goToCallPage();
        }
      }
    });

    prefs = await SharedPreferences.getInstance();

    if (sessionFrom == null && sessionTo == null) {
      await prefs.reload();
      setState(() {
        sessionFrom = prefs.getString('session_from');
        sessionTo = prefs.getString('session_to');
        _isAccept = prefs.getBool('is_accept');

        _callid = prefs.getString('callid');
        _videoMinRecvBandwidth = prefs.getString('videoMinRecvBandwidth');
        _videoMaxSendBandwidth = prefs.getString('videoMaxSendBandwidth');
        _videoMaxRecvBandwidth = prefs.getString('videoMaxRecvBandwidth');
        _videoMinSendBandwidth = prefs.getString('videoMinSendBandwidth');
      });
      print('is_accept : $_isAccept');
      print('sessionFrom2 : $sessionFrom');
    }
  }

  void addPermission() {
    platform.invokeMethod("powerOff");
  }

  void _goToCallPage() {
    if (!isOnCall) {
      isOnCall = true;
      DialVideoCall vcall = DialVideoCall(
        sessionFrom: sessionFrom,
        sessionTo: sessionTo,
        isAnswer: _isAccept == null ? false : true,
        isAccept: _isAccept == null
            ? null
            : _isAccept == true
                ? true
                : false,
        useName: true,
        useMuted: true,
        useSwitchCamera: true,
        callid: _callid,
        videoMinRecvBandwidth: _videoMinRecvBandwidth,
        videoMaxSendBandwidth: _videoMaxSendBandwidth,
        videoMaxRecvBandwidth: _videoMaxRecvBandwidth,
        videoMinSendBandwidth: _videoMinSendBandwidth,
      );
      vcall.startVideoCallDevV2(context).then((value) {
        isOnCall = false;
        sessionFrom = null;
        sessionTo = null;
        _isAccept = null;

        _callid = "0";
        _videoMinRecvBandwidth = "200";
        _videoMaxSendBandwidth = "2000";
        _videoMaxRecvBandwidth = "2000";
        _videoMinSendBandwidth = "200";

        prefs.remove('is_accept');
        prefs.remove('session_from');
        prefs.remove('session_to');

        prefs.remove('callid');
        prefs.remove('videoMinRecvBandwidth');
        prefs.remove('videoMaxSendBandwidth');
        prefs.remove('videoMaxRecvBandwidth');
        prefs.remove('videoMinSendBandwidth');
      });
    }

    prefs.remove('is_accept');
    prefs.remove('session_from');
    prefs.remove('session_to');

    prefs.remove('callid');
    prefs.remove('videoMinRecvBandwidth');
    prefs.remove('videoMaxSendBandwidth');
    prefs.remove('videoMaxRecvBandwidth');
    prefs.remove('videoMinSendBandwidth');

    setState(() {
      _isAccept = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Flutter Dial Video Call Demo'),
      ),
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
                backgroundImage: AssetImage('assets/dial_logo.png')),
            title: Text("Flutter Dial Video Call Demo"),
            subtitle: Text("v 0.0.1"),
          ),
          ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.of(context).pop();
              }),
        ],
      )),
      body: Builder(
        builder: (ctx) => Container(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    enabled: false,
                    minLines: 4,
                    maxLines: 10,
                    controller: _textFirebaseTokenController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        border: OutlineInputBorder(),
                        labelText: 'Firebase token',
                        hintText: 'Enter firebase token'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(new ClipboardData(
                            text: _textFirebaseTokenController.text));
                        final snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('FCM copied to clipboard'),
                        );
                        Scaffold.of(ctx).showSnackBar(snackBar);
                      },
                      child: Text("Copy FCM")),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        addPermission();
                        // DialMakeVideoCall vcall = DialMakeVideoCall(
                        //     callerName: 'mobile1', //this is name user
                        //     useName: true,
                        //     useMuted: true,
                        //     useSwitchCamera: true);
                        // vcall.makeVideoCallDev(context);
                      },
                      child: Text("Make Video Call"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
