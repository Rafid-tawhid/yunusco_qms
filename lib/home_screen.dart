import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nidle_qty/buyer_list_screen.dart';
import 'package:nidle_qty/service_class/hive_service_class.dart';
import 'package:nidle_qty/service_class/notofication_helper.dart';
import 'package:nidle_qty/tabview_buyer_screen.dart';
import 'package:nidle_qty/saved_marked_image.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/custom_button.dart';
import 'package:nidle_qty/widgets/logout_alert.dart';
import 'package:provider/provider.dart';

import 'utils/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    if(Platform.isAndroid){
      NotificationServices.setupPushNotifications(context);
      NotificationServices.initializeNotifications();
    }
    //_getBearerTokenFromServer();

    super.initState();
  }



  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(onPressed: () async {
            await showLogoutAlert(context);
            // Handle logout
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logging out...')),
            );
          }, icon: Icon(Icons.logout))
        ],
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png',height: 120,width: 120,),
             Text(
              'Yunusco QMS',
              style: AppConstants.customTextStyle(24, Colors.black, FontWeight.bold)
            ),
            const SizedBox(height: 30),
            ActionButton(
              icon: Icons.table_chart_rounded,
              text: 'End Table Check',
              color: Colors.blue,
              onPressed: () {
                // Handle first button press
                Navigator.push(context, CupertinoPageRoute(builder: (context)=>BuyerListScreen()));
              },
            ),
            const SizedBox(height: 20),
            ActionButton(
              icon: Icons.rocket_launch,
              text: 'In Process Check',
              color: Colors.deepPurple,
              onPressed: () {

                // if(MediaQuery.of(context).size.width>600){
              // Navigator.push(context, CupertinoPageRoute(builder: (context)=>TouchMarkerScreen()));
                // }
                // else {
                //   Navigator.push(context, CupertinoPageRoute(builder: (context)=>BuyerListScreen()));
                // }

              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Tap menu icon to open drawer',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  void _getBearerTokenFromServer() async{
    //var data=await NotificationServices.getFirebaseBearerToken();
   // debugPrint('Server Key : ${data}');
  }



}