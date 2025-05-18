import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:provider/provider.dart';

import '../models/operation_model.dart';
import '../utils/constants.dart';

class OperationList extends StatefulWidget {
  final List<OperationModel> items;

  const OperationList({super.key, required this.items});

  @override
  State<OperationList> createState() => _OperationListState();
}

class _OperationListState extends State<OperationList> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    getOperations();
    // Select first item automatically when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.items.isNotEmpty) {
        setState(() => selectedIndex = 0);
        final cp = context.read<CountingProvider>();
        cp.getDefectListByOperationId(widget.items[0].operationId.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Operation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
              Icon(Icons.arrow_forward_rounded, color: myColors.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.items.length,

              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                final operation = widget.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange[50] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey[300]!,
                        width: isSelected ? 1 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() => selectedIndex = index);
                          final cp = context.read<CountingProvider>();
                          cp.selectedOperation(operation);
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 12,
                              child: isSelected? Icon(Icons.check_circle,color: Colors.deepOrange,size: 20,):SizedBox(),
                            ),
                            Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    operation.operationName ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.orange[800]
                                          : Colors.grey[800],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }

  void getOperations() async {
    final cp = context.read<CountingProvider>();
    final bp = context.read<BuyerProvider>();
    await cp.getAllOperations(buyerPo: bp.buyerPo!);

    // Ensure first item remains selected after data loads
    if (widget.items.isNotEmpty && selectedIndex == null) {
      setState(() => selectedIndex = 0);
      cp.getDefectListByOperationId(widget.items[0].operationId.toString());
    }
  }
}



