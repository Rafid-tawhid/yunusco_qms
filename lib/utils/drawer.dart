import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/quality_report_screen.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';

import '../all_line_qms_info_details.dart';
import '../home_screen.dart';
import '../line_dropdown_settings.dart';
import '../providers/counting_provider.dart';
import '../widgets/logout_alert.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
         if(DashboardHelpers.userModel!=null) DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                      'images/icon.png'),
                ),
                const SizedBox(height: 10),
                 Text(
                 DashboardHelpers.userModel!.userName?? 'Sarah Johnson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DashboardHelpers.userModel!.designation??'sarah.johnson@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black54),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
              // Navigate to home (already here)
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black54),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            //  Navigator.push(context, MaterialPageRoute(builder: (context)=>LineSettingScreen()));
             Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchDropdownScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black54),
            title: const Text('Production'),
            onTap: () async {
              Navigator.pop(context);
              /// Navigate to this screen from another widget

              var cp = context.read<CountingProvider>();
              var bp = context.read<BuyerProvider>();
              await cp.getTodaysCountingDataHourDetails(bp);
              if(cp.all_hourly_production_List.isNotEmpty){
                Navigator.push(context, CupertinoPageRoute(builder: (context) => AllLineQmsInfoDetails( productionData: cp.all_hourly_production_List,)));
              }

            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {

              await showLogoutAlert(context);
              // Handle logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logging out...')),
              );
            },
          ),
        ],
      ),
    );
  }
}

