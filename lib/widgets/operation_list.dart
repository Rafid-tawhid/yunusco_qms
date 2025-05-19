import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/utils/constants.dart';


class OperationsListWidget extends StatelessWidget {
  final List<Map<String,dynamic>> operations;

  const OperationsListWidget({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...operations.map((op) => Padding(
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
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 12),
                        child: Text(op['value'].toString(),style: customTextStyle(16, Colors.white, FontWeight.bold),),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(op['item']??'', style: customTextStyle(15, Colors.white, FontWeight.w500)),
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
