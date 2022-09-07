import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:dial_videocall_example/page/my_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:wakelock/wakelock.dart';

FirebaseMessaging _messaging = FirebaseMessaging.instance;
//SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _registerNotification();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    home: MyHome(firebaseToken: await _messaging.getToken()),
  ));
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await AppLauncher.openApp(
//   //   androidApplicationId: "com.acs.dial_videocall",
//   // );

//   print("Handling a background message: ${message.messageId}");
//   Wakelock.enable();
//   try {
//     // await platform.invokeMethod('powerOff');
//     // _channel.invokeMethod('wakeFromBackground');
//   } on PlatformException catch (e) {
//     print("Failed to Invoke: '${e.message}'.");
//   }
//   print("Handling a background DONE");
//   // ignore: unnecessary_statements
//   print("Handling a background DONE '${PowerManager.ACQUIRE_CAUSES_WAKEUP}'.");

//   print("WAKE LOCK DONE -------------");
//   if (Platform.isAndroid) {
//     _showIncomingCall(message);
//   }
//   prefs = await SharedPreferences.getInstance();
//   prefs.remove('is_accept');
//   prefs.remove('session_from');
//   prefs.remove('session_to');
// }

// void _showIncomingCall(RemoteMessage message) async {
//   ConnectycubeFlutterCallKit.instance.init(onCallAccepted: (String sessionId,
//       int callType, int callerId, String callerName, Set opponentsIds) async {
//     print('Telepon diangkat');
//     await _saveSession(message.data['session_from'], message.data['session_to'],
//         message.data['record_id'], true);
//     // Your Logic Here When user presses Green Button on the screen.
//     return null;
//   }, onCallRejected: (String sessionId, int callType, int callerId,
//       String callerName, Set opponentsIds) async {
//     print('Telepon diakhiri');
//     _saveSession(message.data['session_from'], message.data['session_to'],
//         message.data['record_id'], false);
//     print('reject ${message.data['session_from']}');

//     await AppLauncher.openApp(
//       androidApplicationId: "com.acs.dial_videocall",
//     );
//     // Your Logic Here When user presses Red Button on the screen.
//     return null;
//   });
//   await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
//     isVisible: true,
//   );

//   await ConnectycubeFlutterCallKit.showCallNotification(
//     sessionId: Uuid().v4(),
//     callType: 1,
//     callerName: message.notification.title,
//     callerId: 0,
//     opponentsIds: {1},
//   );

//   await _saveSession(message.data['session_from'], message.data['session_to'],
//       message.data['record_id'], null);
//   print('sessionFrom ${message.data['session_from']}');
// }

// Future<void> _saveSession(String sessionFrom, String sessionTo, String recordId,
//     bool _isAccept) async {
//   await prefs.setString('session_from', sessionFrom);
//   await prefs.setString('session_to', sessionTo);
//   await prefs.setString('record_id', recordId);
//   await prefs.setBool('is_accept', _isAccept);
//   await prefs.reload();
//   print('Saved user inputs values.');
// }

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
