import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/purchase_order.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';

import 'models/buyer_style_model.dart';

class StyleSelectionScreen extends StatefulWidget {
  const StyleSelectionScreen({Key? key}) : super(key: key);

  @override
  _StyleSelectionScreenState createState() => _StyleSelectionScreenState();
}

class _StyleSelectionScreenState extends State<StyleSelectionScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterStyles(String query) {
    var bp = context.read<BuyerProvider>();
    bp.searchInStyleList(query);
  }

  Future<void> _handleSelection(int index, BuyerStyleModel data) async {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
      }
    });

    if (selectedIndex != null) {
      var bp = context.read<BuyerProvider>();
      bp.setLoadingPo(true);
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      await bp.getBoByStyleOfBuyers(data.style ?? '');
      EasyLoading.dismiss();
      bp.setLoadingPo(false);
      bp.setBuyersStylePoInfo(buyerStyle: data);
      if (bp.poListByStyle.isEmpty) {
        DashboardHelpers.showAlert(msg: 'No Order Found.');
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseOrderSelectionScreen()));
      }
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
                  decoration: InputDecoration(hintText: 'Search styles...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black)),
                  style: TextStyle(color: Colors.black),
                  onChanged: filterStyles,
                )
                : Text('Select Garment Style',style: AppConstants.customTextStyle(18, Colors.black, FontWeight.w500),),
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
      body: Consumer<BuyerProvider>(
        builder:
            (context, pro, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  pro.filteredStyleList.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No styles found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Try a different search term', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                          ],
                        ),
                      )
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: DashboardHelpers.isLandscape(context) ? 4 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: pro.filteredStyleList.length,
                        itemBuilder: (context, index) {
                          final style = pro.filteredStyleList[index];
                          final isSelected = selectedIndex == index;

                          return GestureDetector(
                            onTap: () => _handleSelection(index, style),
                            child: Card(
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isSelected ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                      child: Icon(Icons.style, size: 30, color: Theme.of(context).primaryColor),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(style.style ?? '', textAlign: TextAlign.center, maxLines: 4, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
      ),
    );
  }
}
