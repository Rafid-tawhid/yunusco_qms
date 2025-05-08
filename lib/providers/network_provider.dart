import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class NetworkProvider with ChangeNotifier {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _wasConnected = true;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus.any((status) => status != ConnectivityResult.none);

  NetworkProvider() {
    print('NetworkProvider: Constructor called');
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    print('NetworkProvider: Initializing connectivity check');
    late List<ConnectivityResult> result;
    try {
      print('NetworkProvider: Checking connectivity...');
      result = await _connectivity.checkConnectivity();
      print('NetworkProvider: Initial connectivity result: $result');
    } on PlatformException catch (e) {
      print('NetworkProvider: Error checking connectivity: $e');
      return;
    }
    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    print('\nNetworkProvider: Connection status update received');
    print('NetworkProvider: Previous status: $_connectionStatus');
    print('NetworkProvider: New status: $result');

    _connectionStatus = result;
    notifyListeners();

    final currentlyConnected = isConnected;
    print('NetworkProvider: Currently connected: $currentlyConnected');
    print('NetworkProvider: Was connected: $_wasConnected');

    if (_wasConnected && !currentlyConnected) {
      print('NetworkProvider: Connection lost! Showing alert...');
      _showNoInternetAlert();
    } else if (!_wasConnected && currentlyConnected) {
      print('NetworkProvider: Connection restored!');
    }

    _wasConnected = currentlyConnected;
    print('NetworkProvider: Update complete\n');
  }

  void _showNoInternetAlert() {
    print('NetworkProvider: Displaying no internet alert');
    EasyLoading.showError(
      'No internet connection',
      duration: const Duration(seconds: 4),
      dismissOnTap: true,
    );
  }

  void dispose() {
    super.dispose();
    print('NetworkProvider: Disposing provider');
    _connectivitySubscription.cancel();
  }
}