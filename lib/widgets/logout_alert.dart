import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nidle_qty/login_screen.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';

Future<void> showLogoutAlert(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(), // Close dialog
          ),
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              // Perform logout
              DashboardHelpers.clearUser();
              Navigator.of(context).pop();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            },
          ),
        ],
      );
    },
  );
}

