import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:dial_videocall_example/page/my_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:dial_videocall/dial_videocall.dart';

FirebaseMessaging _messaging = FirebaseMessaging.instance;
SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // _registerNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    home: MyHome(firebaseToken: await _messaging.getToken()),
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DialVideoCall vcall = DialVideoCall(
    sessionFrom: message.data['session_from'],
    sessionTo: message.data['session_to'],
    isAnswer: null,
    isAccept: true,
    useName: true,
    useMuted: true,
    useSwitchCamera: true,
    callid: message.data['callid'],
    videoMinRecvBandwidth: message.data['videoMinRecvBandwidth'],
    videoMaxSendBandwidth: message.data['videoMaxSendBandwidth'],
    videoMaxRecvBandwidth: message.data['videoMaxRecvBandwidth'],
    videoMinSendBandwidth: message.data['videoMinSendBandwidth'],
  );

  await vcall.receivedNotification(message.data['session_to']).then((value) {
    print("DARI CLIENT FIREBASE");
  });

  await print("Handling a background message: ${message.messageId}");
  print("Handling a background data : ${message.data}");
  if (Platform.isAndroid) {
    _showIncomingCall(message);
  }
  prefs = await SharedPreferences.getInstance();
  prefs.remove('is_accept');
  prefs.remove('session_from');
  prefs.remove('session_to');

  prefs.remove('callid');
  prefs.remove('videoMinRecvBandwidth');
  prefs.remove('videoMaxSendBandwidth');
  prefs.remove('videoMaxRecvBandwidth');
  prefs.remove('videoMinSendBandwidth');
}

void _showIncomingCall(RemoteMessage message) async {
  ConnectycubeFlutterCallKit.instance.init(onCallAccepted: (String sessionId,
      int callType, int callerId, String callerName, Set opponentsIds) async {
    print('Telepon diangkat');
    DialVideoCall vcall = DialVideoCall(
      sessionFrom: message.data['session_from'],
      sessionTo: message.data['session_to'],
      isAnswer: true,
      isAccept: true,
      useName: true,
      useMuted: true,
      useSwitchCamera: true,
      callid: message.data['callid'],
      videoMinRecvBandwidth: message.data['videoMinRecvBandwidth'],
      videoMaxSendBandwidth: message.data['videoMaxSendBandwidth'],
      videoMaxRecvBandwidth: message.data['videoMaxRecvBandwidth'],
      videoMinSendBandwidth: message.data['videoMinSendBandwidth'],
    );
    vcall.acceptedCall(message.data['session_to']).then((value) {
      print("DARI CLIENT FIREBASE");
    });

    await _saveSession(
        message.data['session_from'],
        message.data['session_to'],
        message.data['record_id'],
        true,
        message.data['callid'],
        message.data['videoMinRecvBandwidth'],
        message.data['videoMaxSendBandwidth'],
        message.data['videoMaxRecvBandwidth'],
        message.data['videoMinSendBandwidth']);
    // Your Logic Here When user presses Green Button on the screen.
    return null;
  }, onCallRejected: (String sessionId, int callType, int callerId,
      String callerName, Set opponentsIds) async {
    print('Telepon diakhiri');
    DialVideoCall vcall = DialVideoCall(
      sessionFrom: message.data['session_from'],
      sessionTo: message.data['session_to'],
      isAnswer: false,
      isAccept: true,
      useName: true,
      useMuted: true,
      useSwitchCamera: true,
      callid: "0",
      videoMinRecvBandwidth: "200",
      videoMaxSendBandwidth: "2000",
      videoMaxRecvBandwidth: "2000",
      videoMinSendBandwidth: "200",
    );
    vcall.rejectedCall(message.data['session_to']).then((value) {
      print("DARI CLIENT FIREBASE");
    });
    return null;
  });
  await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
    isVisible: true,
  );

  await ConnectycubeFlutterCallKit.showCallNotification(
    sessionId: Uuid().v4(),
    callType: 1,
    callerName: "Panggilan Video Call",
    callerId: 0,
    opponentsIds: {1},
  );

  await _saveSession(
      message.data['session_from'],
      message.data['session_to'],
      message.data['record_id'],
      null,
      message.data['callid'],
      message.data['videoMinRecvBandwidth'],
      message.data['videoMaxSendBandwidth'],
      message.data['videoMaxRecvBandwidth'],
      message.data['videoMinSendBandwidth']);
  print('sessionFrom ${message.data['session_from']}');
}

Future<void> _saveSession(
    String sessionFrom,
    String sessionTo,
    String recordId,
    bool _isAccept,
    String _callid,
    String _videoMinRecvBandwidth,
    String _videoMaxSendBandwidth,
    String _videoMaxRecvBandwidth,
    String _videoMinSendBandwidth) async {
  await prefs.setString('session_from', sessionFrom);
  await prefs.setString('session_to', sessionTo);
  await prefs.setString('record_id', recordId);
  await prefs.setBool('is_accept', _isAccept);

  await prefs.setString('callid', _callid);
  await prefs.setString('videoMinRecvBandwidth', _videoMinRecvBandwidth);
  await prefs.setString('videoMaxSendBandwidth', _videoMaxSendBandwidth);
  await prefs.setString('videoMaxRecvBandwidth', _videoMaxRecvBandwidth);
  await prefs.setString('videoMinSendBandwidth', _videoMinSendBandwidth);

  await prefs.reload();
  print('Saved user inputs values.');
}

void _registerNotification() async {
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  var token = await _messaging.getToken();
  print("tokens : $token");
}
