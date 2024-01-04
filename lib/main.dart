import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_flutter/local_notification.dart';
import 'package:push_notification_flutter/notification_detail_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void initNotificationSettings() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    AuthorizationStatus authStatus = settings.authorizationStatus;
    if (authStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await FirebaseMessaging.instance.getToken();
      print("Firebase Messaging Token: $token");
    } else if (authStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied or has not accepted permission');
    }
  }

  @override
  void initState() {
    super.initState();
    LocalNotification.initialize(flutterLocalNotificationsPlugin);
    initNotificationSettings();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final String payload = message.data['payload'] ?? 'No data';
        _navigateToDetails(payload);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final String payload = message.data['payload'] ?? 'No data';
      _navigateToDetails(payload);
    });

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      print('message $message');

      if (notification != null) {
        LocalNotification.showNotification(
          id: notification.hashCode,
          title: notification.title ?? 'No title',
          body: notification.body ?? 'No body',
          payload: message.data['payload'] ?? 'No payload',
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        );
      }
    });
  }

  void _navigateToDetails(String payload) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailsPage(payload: payload),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Test'),
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          child: ElevatedButton(
              onPressed: () async {
                await LocalNotification.showNotification(
                  id: 0,
                  title: 'Test Notification',
                  body: 'This is a test notification',
                  payload: 'Test Payload',
                  flutterLocalNotificationsPlugin:
                      flutterLocalNotificationsPlugin,
                );
              },
              child: const Text('Send Notification')),
        ),
      ),
    );
  }
}
