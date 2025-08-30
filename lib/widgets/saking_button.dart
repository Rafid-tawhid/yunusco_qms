import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/network_provider.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:provider/provider.dart';

class ShakingWifiDisableWidget extends StatefulWidget {
  const ShakingWifiDisableWidget({super.key});

  @override
  State<ShakingWifiDisableWidget> createState() =>
      _ShakingWifiDisableWidgetState();
}

class _ShakingWifiDisableWidgetState extends State<ShakingWifiDisableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0), // Adjust shaking intensity here
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder:
          (context, pro, _) =>
              pro.wasConnected
                  ? Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.white),
                        Text(
                          'Enable',
                          style: customTextStyle(
                            14,
                            Colors.white,
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  : SlideTransition(
                    position: _offsetAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'WIFI DISABLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
    );
  }
}
