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
import 'package:nidle_qty/widgets/network_alert.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'models/local_send_data_model.dart';
import 'models/send_data_model.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid){
    await Firebase.initializeApp();  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(SendDataModelAdapter());
    await Hive.openBox<SendDataModel>('sendDataBox');
    await HiveLocalSendDataService.init();
  } catch (e) {
    print('Error initializing Hive: $e');
    await Hive.deleteBoxFromDisk('localSendDataBox');
    await Hive.openBox('localSendDataBox');
  }



  await DashboardHelpers.clearDataIfNewDay();


  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>BuyerProvider()),
        ChangeNotifierProvider(create: (_)=>CountingProvider()),
        ChangeNotifierProvider(create: (_)=>NetworkProvider()),
      ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yunusco QMS',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        print('App: MaterialApp builder called');

        // Initialize network listener
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('App: Initializing network listener');
          Provider.of<NetworkProvider>(context, listen: false).initConnectivity();
        });

        return EasyLoading.init()(context, child);
      },
      home: LauncherScreen(),
    );
  }
}


