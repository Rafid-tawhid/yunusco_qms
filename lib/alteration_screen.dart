import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/models/checked_enum.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/widgets/operations_list.dart';
import 'package:provider/provider.dart';

import 'alteration_testing_screen.dart';

class AlterationReasonScreen extends StatefulWidget {
  final String form;

  const AlterationReasonScreen({super.key, required this.form});

  @override
  _AlterationReasonScreenState createState() => _AlterationReasonScreenState();
}

class _AlterationReasonScreenState extends State<AlterationReasonScreen> {
  final List<String> selectedReasons = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    // selectedReasons.addAll(widget.existingReasons);
    getFirstDefectReason();
  }

  void _toggleReason(String reason) {
    setState(() {
      if (selectedReasons.contains(reason)) {
        selectedReasons.remove(reason);
      } else {
        selectedReasons.add(reason);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Select Alteration Reasons')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180, // Adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Select Operation :'), Icon(Icons.arrow_forward_rounded)]),
                ),
                Consumer<CountingProvider>(builder: (context, pro, _) => OperationList(items: pro.allOperations)),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16), child: Text('Select Reasons :')),

          Expanded(
            child: Consumer<CountingProvider>(
              builder:
                  (context, pro, _) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pro.allDefectList.length,
                    itemBuilder: (context, index) {
                      final reason = pro.allDefectList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          title: Text(reason.defectName ?? ''),
                          value: selectedReasons.contains(reason.defectName),
                          onChanged: (value) {
                            setState(() {
                              selectedIndex = index;
                            });
                            debugPrint('DefectModels ${reason.toJson()}');
                            _toggleReason(reason.defectName ?? '');
                          },
                          secondary: const Icon(Icons.warning_amber_rounded),
                        ),
                      );
                    },
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  var cp = context.read<CountingProvider>();
                  var bp = context.read<BuyerProvider>();

                  //set counting data locally
                  var checked = await cp.saveCountingDataLocally(
                    bp,
                    from: true,
                    info: {'operationId': cp.allDefectList[selectedIndex??0].operationId, 'defectId': cp.allDefectList[selectedIndex??0].defectId},
                    status: getStatus(widget.form),
                  );

                  if (getStatus(widget.form) == CheckedStatus.alter && checked) {
                    cp.alterItem();
                  } else {
                    cp.rejectItem();
                  }

                  Navigator.pop(context, selectedReasons);
                },
                child: Text('CONFIRM ${widget.form.toUpperCase()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getFirstDefectReason() async {
    var cp = context.read<CountingProvider>();
    cp.getDefectListByOperationId('1');
  }

  getStatus(String form) {
    if(form=='alter'){
      return '2';
    }
    else {
      return '4';
    }
  }
}
