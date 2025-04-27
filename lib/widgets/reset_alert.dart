import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nidle_qty/login_screen.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:provider/provider.dart';

import '../models/send_data_model.dart';
import '../providers/buyer_provider.dart';

Future<void> showResetConfirmationDialog(BuildContext context, BuyerProvider buyerPro) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to close
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('Are you sure you want to reset all data? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text(
              'Reset All',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog first
              var cuntingPro=context.read<CountingProvider>();
              await _performFullReset(buyerPro,cuntingPro); // Perform the reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset')),
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            },
          ),
        ],
      );
    },
  );
}

Future<void> _performFullReset(BuyerProvider buyerPro,CountingProvider counterPro) async {
  try {

    // 1. Clear Hive data
    final box = Hive.box<SendDataModel>('sendDataBox');
    await box.clear();
    buyerPro.clearStyleAndPoList();
    // counterPro.resetAllCount();
    debugPrint('All data has been reset successfully');
  } catch (e) {
    debugPrint('Error during reset: $e');
    // You might want to show an error message here
  }
}