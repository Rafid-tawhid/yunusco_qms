import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:provider/provider.dart';

import '../models/operation_model.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: SizedBox(
        height: 160, // Slightly taller for better touch targets
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.5, // Better aspect ratio for text
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            final operation = widget.items[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(4),
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
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() => selectedIndex = index);
                    final cp = context.read<CountingProvider>();
                    cp.selectedOperation(operation);
                 //   cp.getDefectListByOperationId(operation.operationId.toString());
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            operation.operationName ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.orange[800] : Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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



