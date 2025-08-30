import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/providers/network_provider.dart';
import 'package:nidle_qty/service_class/hive_service_class.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/launcher_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  try {
    await HiveLocalSendDataService.init();
  } catch (e) {
    print('Error initializing Hive: $e');
    await Hive.deleteBoxFromDisk('localSendDataBox');
    await Hive.openBox('localSendDataBox');
  }

  var isNewDay = await DashboardHelpers.clearDataIfNewDay();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BuyerProvider()),
        ChangeNotifierProvider(create: (_) => CountingProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: MyApp(isNewDay: isNewDay),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isNewDay;
  const MyApp({Key? key, required this.isNewDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yunusco QMS',
      theme: ThemeData(useMaterial3: true),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Initialize network listener
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('App: Initializing network listener');
          Provider.of<NetworkProvider>(
            context,
            listen: false,
          ).initConnectivity();
        });

        return EasyLoading.init()(context, child);
      },
      home: LauncherScreen(isNewDay: isNewDay),
    );
  }
}
