
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:nidle_qty/service_class/api_services.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';

class NotificationServices {

  static Future<AccessToken> getFirebaseBearerToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(await rootBundle.loadString('images/utils/server_key.json')));

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);

    final token = await client.credentials.accessToken;
    client.close();

    return token;
  }



  static Future<void> setupPushNotifications(BuildContext context) async {
    try {
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

      // 1. Request permission (platform-aware)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true, // iOS-only: Allow sending notifications without explicit permission
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');

      // 2. Handle permission denied or limited (e.g., iOS "provisional")
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        await _openAppSettingsOrShowRationale(context);
        return;
      }

      // 3. Get and handle FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      debugPrint("FCM Token: $token");
      await _sendTokenToServer(token); // Send to your backend

      // 4. Handle token refresh (e.g., on app restore or reinstall)
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint("FCM Token refreshed: $newToken");
        _sendTokenToServer(newToken);
      });

      // 5. Set up foreground/background message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageClick);

      // 6. Configure for iOS/macOS
      if (Platform.isIOS || Platform.isMacOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true, // Show heads-up notification
          badge: true, // Update app badge
          sound: true, // Play sound
        );
      }

      // 7. Handle initial notification (app opened from terminated state)
      RemoteMessage? initialMessage =
      await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

    } catch (e, stackTrace) {
      debugPrint('Error setting up push notifications: $e\n$stackTrace');
      // Optional: Log error to analytics (e.g., Sentry, Firebase Crashlytics)
    }
  }

// --- Helper Methods ---

  static Future<void> _openAppSettingsOrShowRationale(BuildContext context) async {
    // Show a dialog explaining why permissions are needed
    bool? shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications Disabled'),
        content: Text(
          'Enable notifications in Settings to receive important updates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await AppSettings.openAppSettings(); // Using the `app_settings` package
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    // Implement your API call here
    debugPrint('Sending token to server...');
    ApiService apiService=ApiService();

    var response=await apiService.postData('api/user/CheckDeviceToken', {
      "FirebaseDeviceToken": "$token",
      "Userid":"${DashboardHelpers.userModel!.userId}",
      "roleId": "${DashboardHelpers.userModel!.roleId}"
    });
    debugPrint('Token Response ${response}');
  }


 static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    _showNotification(message); // Your existing notification display logic
  }

 static void _handleBackgroundMessageClick(RemoteMessage message) {
    debugPrint('App opened from background: ${message.data}');
    _handleNotificationClick(message); // Navigate to a specific screen
  }


  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClickFromTap(response.payload);
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }



  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

  static void _handleNotificationClick(RemoteMessage message) {
    debugPrint("Notification clicked with data: ${message.data}");
    // Add your navigation logic here based on message data
  }

 static void _handleNotificationClickFromTap(String? payload) {
    if (payload != null) {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      debugPrint("Notification clicked with payload: $data");
      // Add your navigation logic here based on payload
    }
  }
}



//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   //
//   Future<void> requestForPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('Permission granted');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('Permission granted provosional');
//     } else {
//       AppSettings.openAppSettings(type: AppSettingsType.notification)
//           .then((value) {});
//       print('Permission denied');
//     }
//   }
//
//   //
//   initLocalNotification(BuildContext context, RemoteMessage message) async {
//     var androidSettings =
//     AndroidInitializationSettings('@mipmap/launcher_icon');
//     var iosSettings = const DarwinInitializationSettings();
//
//     var intialization =
//     InitializationSettings(android: androidSettings, iOS: iosSettings);
//
//     await _localNotificationsPlugin.initialize(intialization,
//         onDidReceiveNotificationResponse: (payload) {
//           //this is called when notification is clicked
//           handleMessage(context, message);
//         });
//   }
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> showNotification(RemoteMessage message) async {
//     // Create a notification channel for Android
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       Random.secure().nextInt(1000).toString(),
//       'High Importance Notification',
//       importance: Importance.high,
//     );
//
//     // Android notification details
//     AndroidNotificationDetails androidNotificationDetails =
//     AndroidNotificationDetails(
//       channel.id.toString(),
//       channel.name.toString(),
//       channelDescription: 'My loading description',
//       priority: Priority.high,
//       importance: Importance.max,
//       ticker: 'Ticker',
//     );
//
//     // iOS notification details
//     DarwinNotificationDetails iosNotificationDetails =
//     DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     // Notification details for both platforms
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );
//
//     // Show the notification
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//       notificationDetails,
//     );
//
//     print('Notification shown successfully.');
//   }
//
// // Initialize the local notifications plugin (should be called in your main method or initState)
//   Future<void> initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//
//
//   Future<String> getTokens() async {
//     String? token = await messaging.getToken();
//     return token!;
//   }
//
//   void isTokenExperied() {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//       print('refresh');
//     });
//   }
//
//   //
//   void handleMessage(BuildContext context, RemoteMessage message) {
//     print('Notification RemoteMessage ${message.data.toString()}');
//     if (message.data['status'] == 'Provider Approved.') {}
//   }
//   //
//   // Future<void> setupInteractMessage(BuildContext context) async {
//   //   //when app is terminated
//   //   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//   //
//   //   if (initialMessage != null) {
//   //     handleMessage(context, initialMessage);
//   //   }
//   //
//   //   //when app is in background
//   //   FirebaseMessaging.onMessageOpenedApp.listen((event) {
//   //     handleMessage(context, event);
//   //   });
//   // }
//   //
//   // downloadFile(String url, String fileName) async {
//   //   final directory = await getApplicationDocumentsDirectory();
//   //   final filePath = '${directory.path}/$fileName';
//   //   final response = await http.get(Uri.parse(url));
//   //   final file = File(filePath);
//   //   await file.writeAsBytes(response.bodyBytes);
//   //   return filePath;
//   // }
//
//   // static sendDeviceTokenToServerForSendingPushNotification(String token) async {
//   //   var data;
//   //
//   //   String deviceInfo = await getDeviceData();
//   //   print('device INFO ${deviceInfo}');
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse('https://pencilbox.edu.bd/api/save_new_device'),
//   //       body: {'device_id': token, 'device_info': deviceInfo},
//   //     );
//   //     if (response.statusCode == 200) {
//   //       data = jsonDecode(response.body.toString());
//   //       print('DEVICE TOKEN RESPONSE ${data}');
//   //       return data;
//   //     } else {
//   //       data = jsonDecode(response.body.toString());
//   //       // print('DEVICE TOKEN FALSE ${data}');
//   //       return data;
//   //     }
//   //   } catch (e) {
//   //     print('DEVICE TOKEN ERROR ${e}');
//   //     return data;
//   //   }
//   // }
//   //
//   // static Future<String> getDeviceData() async {
//   //   String deviceAllInfo = '';
//   //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   //   if (Platform.isAndroid) {
//   //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//   //     print('Device Model: ${androidInfo.model}');
//   //     print('Android Version: ${androidInfo.version.release}');
//   //     deviceAllInfo = {'Device Model': androidInfo.model, 'Android Version': androidInfo.version.release, 'Device Name': androidInfo.brand}.toString();
//   //   } else if (Platform.isIOS) {
//   //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//   //     print('Device Model: ${iosInfo.utsname.machine}');
//   //     print('iOS Version: ${iosInfo.systemVersion}');
//   //     deviceAllInfo = {'Device Model': iosInfo.model, 'Android Version': iosInfo.systemVersion, 'Device Name': iosInfo.name}.toString();
//   //   }
//   //
//   //   print('DEVICE ALL INFO ${deviceAllInfo}');
//   //
//   //   return deviceAllInfo;
//   // }
//   //
//   // static Future<dynamic> getAllNotification() async {
//   //   var data;
//   //   final apiKey = 'pencilbox@app.notify';
//   //   final url = Uri.parse('https://pencilbox.edu.bd/api/get_latest_notifications?api_key=$apiKey');
//   //
//   //   try {
//   //     final response = await http.get(url);
//   //     print('Notification : ${response}');
//   //
//   //     if (response.statusCode == 200) {
//   //       data = jsonDecode(response.body.toString());
//   //
//   //       return data;
//   //     } else {
//   //       data = jsonDecode(response.body.toString());
//   //       // print('DEVICE TOKEN FALSE ${data}');
//   //       data = null;
//   //       return data;
//   //     }
//   //   } catch (e) {
//   //     data = null;
//   //     return data;
//   //   }
//   // }
//   //
//   Future forGroundMessage() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//         alert: true, badge: true, sound: true);
//   }
//
//   Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
// }


