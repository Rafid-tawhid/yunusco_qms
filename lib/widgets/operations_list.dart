import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
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
    getOperations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 150, // 2 rows × 80px each (160/2)
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 rows
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: .4, // Wider items for better text display
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = isSelected ? null : index;
                });
                var cp=context.read<CountingProvider>();
                cp.getDefectListByOperationId(widget.items[index].operationId.toString());
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          widget.items[index].operationName??'',
                          style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void getOperations() async{
    var cp=context.read<CountingProvider>();
    var bp=context.read<BuyerProvider>();
    cp.getAllOperations(buyerPo: bp.buyerPo!);
  }
}



