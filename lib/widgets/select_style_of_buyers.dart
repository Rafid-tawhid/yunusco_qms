import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buyer_provider.dart';

class SelectStyleOfBuyers extends StatefulWidget {
  const SelectStyleOfBuyers({super.key});

  @override
  State<SelectStyleOfBuyers> createState() => _SelectStyleOfBuyersState();
}

class _SelectStyleOfBuyersState extends State<SelectStyleOfBuyers> {
  String? selectedStyle;
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _focusNode.unfocus();
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Search Style',
                  hintText: 'Type style code',
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
                  bp.searchInStyleList(query);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.5,
                child: Consumer<BuyerProvider>(
                  builder: (context, pro, _) {
                    // Create a dedicated ScrollController
                    final ScrollController _scrollController = ScrollController();

                    if (pro.loadingStyle) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (pro.filteredStyleList.isEmpty) {
                      return const Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return Scrollbar(
                      controller: _scrollController, // Assign controller here
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController, // And here
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children: pro.filteredStyleList.map((e) {
                            bool isSelected = e.style.toString() == selectedStyle;
                            return ChoiceChip(
                              label: Text(e.style.toString()),
                              selected: isSelected,
                              onSelected: (selected) async {
                                setState(() {
                                  selectedStyle = isSelected ? null : e.style;
                                });
                                var bp = context.read<BuyerProvider>();
                                bp.setLoadingPo(true);
                                await bp.getBoByStyleOfBuyers(e.style.toString());
                                bp.setLoadingPo(false);
                                bp.setBuyersStylePoInfo(buyerStyle: e);
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
