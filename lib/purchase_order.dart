import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/quality_check_screen.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';

import 'models/send_data_model.dart';

class PurchaseOrderSelectionScreen extends StatefulWidget {
  const PurchaseOrderSelectionScreen({super.key});

  @override
  _PurchaseOrderSelectionScreenState createState() => _PurchaseOrderSelectionScreenState();
}

class _PurchaseOrderSelectionScreenState extends State<PurchaseOrderSelectionScreen> {
  TextEditingController searchController = TextEditingController();
  PoModels? _selectedOrder;
  bool isSearching = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // 1. Validate if an order is selected
    if (_selectedOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a purchase order')));
      return;
    }

    final buyerProvider = context.read<BuyerProvider>();
    final countingProvider = context.read<CountingProvider>();
    final box = Hive.box<SendDataModel>('sendDataBox');
    final sendData = box.get('sendDataKey');

    // Handle different PO scenarios
    if (sendData != null && sendData.po == _selectedOrder!.po) {
      debugPrint('PURCHASE ORDER PREVIOUS VALUE SELECTED VALUE SAME');
      countingProvider.getCountingDataLocally(); // Load cached data for next page
    } else if (sendData != null && sendData.po != _selectedOrder!.po) {
      debugPrint('PURCHASE ORDER New PO selected - Resetting counts ${sendData.po}');
      countingProvider.resetAllCount(); // Reset counts for a new PO
    }

    try {
      // Show loading indicator
      EasyLoading.show(maskType: EasyLoadingMaskType.black);

      // Update the selected PO and fetch data
      buyerProvider.setBuyersStylePoInfo(buyerPO: _selectedOrder);
      await Future.wait([buyerProvider.getColor(_selectedOrder!.po), buyerProvider.getSize(_selectedOrder!.po)]);

      // Navigate to the next screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QualityControlScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: ${e.toString()}')));
      debugPrint('Error in _navigateToNextScreen: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: 'Search orders...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black)),
                  style: TextStyle(color: Colors.black),
                  onChanged: filterOrders,
                )
                : Text('Select Purchase Order', style: AppConstants.customTextStyle(18, Colors.black, FontWeight.w500)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchController.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<BuyerProvider>(
              builder: (context, pro, _) {
                if (pro.filteredPoListByStyle.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('Try a different search or filter', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pro.filteredPoListByStyle.length,
                  itemBuilder: (context, index) {
                    final po = pro.filteredPoListByStyle[index];
                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: RadioListTile<PoModels>(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        title: Text(po.po ?? 'No PO Number', style: AppConstants.customTextStyle(16, Colors.black, FontWeight.w500)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Supplier: ${po.style ?? 'N/A'}', style: TextStyle(color: Colors.grey[600]))]),
                        value: po,
                        groupValue: _selectedOrder,
                        onChanged: (value) {
                          setState(() {
                            _selectedOrder = value;
                          });
                        },
                        activeColor: Colors.blueAccent,
                        secondary: Icon(Icons.inventory_2_outlined, color: Colors.grey[600]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(backgroundColor: _selectedOrder == null ? null : Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('PROCEED WITH SELECTED ORDER', style: TextStyle(color: _selectedOrder == null ? null : Colors.white, fontSize: 16)),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  void filterOrders(String query) {
    var bp = context.read<BuyerProvider>();
    bp.searchPurchaseOrderList(query);
  }
}
