import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/login_screen.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';

import '../home_screen.dart';
import '../line_dropdown_settings.dart'; // For SVG logos

class LauncherScreen extends StatefulWidget {
  final bool isNewDay;

  const LauncherScreen({Key? key, required this.isNewDay}) : super(key: key);

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    var token = await DashboardHelpers.getString('token');
    if (token != '' && widget.isNewDay == false) {
      DashboardHelpers.setUserInfo();
      DashboardHelpers.setToken(token);
      var section = await DashboardHelpers.getString('section');
      var line = await DashboardHelpers.getString('selectedLine');
      if (section == '' && line == '') {
        debugPrint('This is calling section ${section} and ${line}');
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => SearchDropdownScreen()),
        );
      } else {
        debugPrint('Line :${line}');
        debugPrint('Sec :${section}');
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo (Replace with your asset)
                Image.asset(
                  'images/logo.png',
                  height: 120,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 30),
                // App Name with Typing Animation
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'QMS',
                      textStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
                const SizedBox(height: 20),
                // Loading Indicator with Custom Design
                SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
