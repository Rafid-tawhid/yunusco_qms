import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buyer_provider.dart';

class SelectPurchaseOrder extends StatefulWidget {
  const SelectPurchaseOrder({super.key});

  @override
  State<SelectPurchaseOrder> createState() => _SelectPurchaseOrderState();
}

class _SelectPurchaseOrderState extends State<SelectPurchaseOrder> {
  String? selectedPO;
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Search Purchase Order',
                  hintText: 'Type PO Code',
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
                  bp.searchPurchaseOrderList(query);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.sizeOf(context).width / 2,
                child: Consumer<BuyerProvider>(
                  builder: (context, pro, _) {
                    // Create a dedicated ScrollController
                    final ScrollController _scrollController = ScrollController();

                    if (pro.loadingPurchase) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (pro.filteredPoListByStyle.isEmpty) {
                      return const Center(
                        child: Text(
                          'No purchase orders found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        primary: false, // Disable primary scroll controller
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: pro.filteredPoListByStyle.map((e) {
                            bool isSelected = selectedPO == e.po;
                            return ChoiceChip(
                              label: Text(e.po.toString()),
                              selected: isSelected,
                              onSelected: (selected) {
                                // Your selection logic here
                                setState(() {
                                  selectedPO=e.po;
                                });

                                var bp=context.read<BuyerProvider>();
                                bp.setBuyersStylePoInfo(buyerPO: e);
                              },
                              selectedColor: Colors.blue.shade200,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.blue.shade900 : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
