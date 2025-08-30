import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NetworkProvider with ChangeNotifier {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool wasConnected = true;
  Timer? _toastTimer;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isConnected =>
      _connectionStatus.any((status) => status != ConnectivityResult.none);

  NetworkProvider() {
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
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
      // Internet lost - start showing periodic toasts
      _startPeriodicToasts();
    } else if (!wasConnected && currentlyConnected) {
      // Internet restored - show immediate toast and cancel timer
      _showToast("Network connection restored", Colors.green);
      _cancelPeriodicToasts();
    }

    wasConnected = currentlyConnected;
  }

  void _startPeriodicToasts() {
    // Show first toast immediately
    _showToast("No internet connection", Colors.red);

    // Then repeat every minute
    _toastTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _showToast("Still no internet connection", Colors.red);
    });
  }

  void _cancelPeriodicToasts() {
    _toastTimer?.cancel();
    _toastTimer = null;
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _cancelPeriodicToasts();
    super.dispose();
  }
}
