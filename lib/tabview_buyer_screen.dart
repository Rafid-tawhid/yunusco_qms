import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/quality_check_screen.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/select_purchase_order.dart';
import 'package:nidle_qty/widgets/select_style_of_buyers.dart';
import 'package:provider/provider.dart';

class TabviewBuyerScreen extends StatefulWidget {
  const TabviewBuyerScreen({super.key});

  @override
  State<TabviewBuyerScreen> createState() => _TabviewBuyerScreenState();
}

class _TabviewBuyerScreenState extends State<TabviewBuyerScreen> {
  String? selectedId;
  String? selectedPO;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // Reset to default (portrait+landscape) when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Order Selection'),
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      // drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Buyer List
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: const TabBuyerListScreen(),
                        ),
                      ),
                      // Right side - Styles and another list
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Styles Section
                              SelectStyleOfBuyers(),
                              const SizedBox(height: 8),
                              // Purchase Order Section
                              SelectPurchaseOrder(),
                              const SizedBox(height: 8),
                              Consumer<BuyerProvider>(
                                builder:
                                    (context, pro, _) => Center(
                                      child: ElevatedButton(
                                        onPressed:
                                            (pro.buyerInfo != null &&
                                                    pro.buyerStyle != null &&
                                                    pro.buyerPo != null)
                                                ? () async {
                                                  //get color and size
                                                  await pro.getColor(
                                                    pro.buyerPo!.po,
                                                  );
                                                  await pro.getSize(
                                                    pro.buyerPo!.po,
                                                  );

                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder:
                                                          (context) =>
                                                              QualityControlScreen(),
                                                    ),
                                                  );
                                                }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabBuyerListScreen extends StatefulWidget {
  const TabBuyerListScreen({super.key});

  @override
  State<TabBuyerListScreen> createState() => _TabBuyerListScreenState();
}

class _TabBuyerListScreenState extends State<TabBuyerListScreen> {
  String? selectedBuyer;
  String searchQuery = '';
  int? selectedBuyerCode;

  @override
  void initState() {
    getBuyerList();
    super.initState();
  }

  void getBuyerList() async {
    var bp = context.read<BuyerProvider>();
    var data = await bp.getAllBuyerList();
    if (data == false) {
      DashboardHelpers.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Select Buyer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Buyers',
              hintText: 'Type buyer name/code',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (query) {
              var bp = context.read<BuyerProvider>();
              bp.searchInBuyerList(query);
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<BuyerProvider>(
            builder:
                (context, pro, _) =>
                    pro.filteredBuyers.isEmpty
                        ? Center(child: Text('No buyer found.'))
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: pro.filteredBuyers.length,
                          separatorBuilder:
                              (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                          itemBuilder: (context, index) {
                            final buyer = pro.filteredBuyers[index];
                            final isSelected = selectedBuyerCode == buyer.code;

                            return InkWell(
                              onTap: () async {
                                setState(() {
                                  selectedBuyerCode = int.parse(
                                    buyer.code.toString(),
                                  );
                                });
                                debugPrint('selected buyer ${buyer}');
                                var bp = context.read<BuyerProvider>();
                                bp.setLoadingStyle(true);
                                var res = await bp.getStyleDataByBuyerId(
                                  buyer.code.toString(),
                                );
                                bp.setLoadingStyle(false);
                                //clear style and po and set code
                                bp.clearStyleAndPoList();
                                bp.setBuyersStylePoInfo(buyerInfo: buyer);
                                //navigate to login if fails api
                                if (res == false) {
                                  DashboardHelpers.navigateToLogin(context);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue.shade50
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buyer.name ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? Colors.blue.shade800
                                                      : Colors.grey.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Code: ${buyer.code}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isSelected
                                                      ? Colors.blue.shade600
                                                      : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.blue.shade600,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
          ),
        ),
      ],
    );
  }
}
