import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../widgets/network_alert.dart';

class NetworkProvider with ChangeNotifier {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool wasConnected = true;
  bool _isDialogShowing = false;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus.any((status) => status != ConnectivityResult.none);

  NetworkProvider() {
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
      return;
    }
    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus = result;
    notifyListeners();

    final currentlyConnected = isConnected;

    if (wasConnected && !currentlyConnected) {
      _showNoInternetAlert();
    } else if (!wasConnected && currentlyConnected) {
      _hideNoInternetAlert();
    }

    wasConnected = currentlyConnected;
  }

  void _showNoInternetAlert() {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DashboardHelpers.showCustomAnimatedDialog(
        context: navigatorKey.currentContext!,
        height: 300,
        dismiss: false,
        child: const NoInternetDialog(),
      );
    });
  }

  void _hideNoInternetAlert() {
    _isDialogShowing = false;
    Navigator.of(navigatorKey.currentContext!).pop();
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}