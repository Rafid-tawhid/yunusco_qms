import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/widgets/operations_list.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Select Reasons', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [myColors.primaryColor, Colors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operation Selection Section
          // Reasons List
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
                    child: Consumer<CountingProvider>(builder: (context, pro, _) => OperationList(items: pro.allOperations)),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Consumer<CountingProvider>(
                        builder:
                            (context, pro, _) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Select Reasons:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]))]),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: pro.allDefectList.length,
                                      itemBuilder: (context, index) {
                                        final reason = pro.allDefectList[index];
                                        return Container(
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
                                          child: Card(
                                            margin: EdgeInsets.zero,
                                            elevation: 0,
                                            color: selectedIndex == index ? Colors.orange[50] : Colors.white,
                                            child: CheckboxListTile(
                                              title: Text(reason.defectName ?? '', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[800])),
                                              value: selectedReasons.contains(reason.defectName),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedIndex = index;
                                                });
                                                debugPrint('DefectModels ${reason.toJson()}');
                                                _toggleReason(reason.defectName ?? '');
                                              },
                                              secondary: Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                                              controlAffinity: ListTileControlAffinity.leading,
                                              activeColor: Colors.orange,
                                              dense: true,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: myColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  shadowColor: Colors.orange.withOpacity(0.5),
                ),
                onPressed:
                    selectedIndex == null || selectedReasons.isEmpty
                        ? null
                        : () async {
                          var cp = context.read<CountingProvider>();
                          var bp = context.read<BuyerProvider>();
                          if (getStatus(widget.form) == '2') {
                            cp.alterItem();
                          } else {
                            cp.rejectItem();
                          }

                          cp.addDataToLocalList(
                            bp,
                            info: {'operationId':cp.operation==null?0: cp.operation!.operationId, 'defectId': cp.allDefectList[selectedIndex ?? 0].defectId, 'operationDetailsId':cp.operation==null?0: cp.operation!.operationDetailsId},
                            status: getStatus(widget.form),
                          );

                          //add to temp defect list
                          selectedReasons.forEach((e){
                            cp.addTempDefectList(e);
                          });


                          Navigator.pop(context, selectedReasons);
                        },
                child: const Text('CONFIRM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  void getFirstDefectReason() async {
    var cp = context.read<CountingProvider>();
    if (cp.allDefectList.isEmpty) {
      cp.getDefectListByOperationId('1');
    }
  }

  String getStatus(String form) {
    return form == 'alter' ? '2' : '4';
  }
}

//
