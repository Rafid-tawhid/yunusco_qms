import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/style_list_screen.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';

class BuyerListScreen extends StatefulWidget {
  @override
  _BuyerListScreenState createState() => _BuyerListScreenState();
}

class _BuyerListScreenState extends State<BuyerListScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) {
      getBuyerList();
    });

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: isSearching ? _buildSearchField() :  Text('Buyer List',style: AppConstants.customTextStyle(18, Colors.black, FontWeight.w500),),
        centerTitle: true,
        elevation: 0,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                isSearching
                    ? IconButton(key: const ValueKey('close'), onPressed: _toggleSearch, icon: const Icon(Icons.close))
                    : IconButton(key: const ValueKey('search'), onPressed: _toggleSearch, icon: const Icon(Icons.search)),
          ),
        ],
      ),
      body: Consumer<BuyerProvider>(
        builder:
            (context, pro, _) => Container(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade50, Colors.white])),
              child:
                  pro.loadingBuyer
                      ? Center(child: CircularProgressIndicator())
                      : pro.filteredBuyers.isEmpty
                      ? Center(child: Text('No Item Found'))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pro.filteredBuyers.length,
                        itemBuilder: (context, index) {
                          final buyer = pro.filteredBuyers[index];
                          return Card(
                            elevation: 2,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                                alignment: Alignment.center,
                                child: Text(buyer.code.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                              title: Text(buyer.name ?? '', style: AppConstants.customTextStyle(16, Colors.black, FontWeight.w600),),
                              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                              onTap: () async {
                                debugPrint('selected buyer ${buyer}');
                                var bp = context.read<BuyerProvider>();
                                bp.setLoadingStyle(true);
                                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                                var res = await bp.getStyleDataByBuyerId(buyer.code.toString());
                                EasyLoading.dismiss();
                                bp.setLoadingStyle(false);
                                //clear style and po and set code
                                bp.
                                clearStyleAndPoList();
                                bp.setBuyersStylePoInfo(buyerInfo: buyer);
                                //navigate to login if fails api
                                if (res == false) {
                                  DashboardHelpers.navigateToLogin(context);
                                }

                                Navigator.push(context, MaterialPageRoute(builder: (context) => StyleSelectionScreen()));
                              },
                            ),
                          );
                        },
                      ),
            ),
      ),
    );
  }

  void getBuyerList() async {
    var bp = context.read<BuyerProvider>();
    bp.setLoadingBuyer(true);
    var data = await bp.getAllBuyerList();
    bp.setLoadingBuyer(false);
    if (data == false) {
      DashboardHelpers.navigateToLogin(context);
    }
  }

  Widget _buildSearchField() {
    var mp = context.read<BuyerProvider>();
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(hintText: 'Search buyer...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.black.withOpacity(0.7))),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      onChanged: (query) async {
        mp.setLoadingStyle(true);
        mp.searchInBuyerList(query.toString());
        await Future.delayed(Duration(milliseconds: 500));
        mp.setLoadingStyle(false);
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        // Clear search results if needed
        // context.read<BuyerProvider>().clearSearch();
      }
    });
  }
}
