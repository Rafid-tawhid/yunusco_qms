import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/utils/constants.dart';


class OperationsListWidget extends StatelessWidget {
  final List<Map<String,dynamic>> operations;

  const OperationsListWidget({super.key, required this.operations});
//
  @override
  Widget build(BuildContext context) {
    // Create a sorted copy of the operations list
    final sortedOperations = List<Map<String, dynamic>>.from(operations)
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
    //
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sortedOperations.map((op) => Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                  color: myColors.blackSecond
              ),
              child: Row(
                children: [
                  Container(
                      alignment: Alignment.center,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                        child: Text(
                          op['value'].toString(),
                          style: customTextStyle(16, Colors.white, FontWeight.bold),
                        ),
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                        op['item'] ?? '',
                        style: customTextStyle(15, Colors.white, FontWeight.w500)
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

}
