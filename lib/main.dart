import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/launcher_screen.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'models/send_data_model.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid){
    await Firebase.initializeApp();  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  await Hive.initFlutter();
  Hive.registerAdapter(SendDataModelAdapter());
  await Hive.openBox<SendDataModel>('sendDataBox');
  await DashboardHelpers.clearDataIfNewDay();


  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>BuyerProvider()),
        ChangeNotifierProvider(create: (_)=>CountingProvider()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yunusco QMS',
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LauncherScreen(),
    );
  }
}

