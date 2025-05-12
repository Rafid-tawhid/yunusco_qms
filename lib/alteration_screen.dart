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
  int? selectedNumber;

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
        title: const Text('Select Alteration Reasons', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [myColors.primaryColor, Colors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operation Selection Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Operation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                    Icon(Icons.arrow_forward_rounded, color: myColors.primaryColor),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<CountingProvider>(builder: (context, pro, _) => OperationList(items: pro.allOperations)),
              ],
            ),
          ),

          // Reason Selection Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16,),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Reasons:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                Container(
                  width: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    isExpanded: true,
                    value: selectedNumber,
                    hint: const Text('(0)', style: TextStyle(color: Colors.grey)),
                    icon: Icon(Icons.arrow_drop_down, color: myColors.primaryColor),
                    items: List.generate(21, (i) => DropdownMenuItem(value: i, child: Text('$i', style: const TextStyle(fontSize: 14)))),
                    onChanged: (value) {
                      setState(() => selectedNumber = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Reasons List
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16,right: 16,top: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Consumer<CountingProvider>(
                  builder:
                      (context, pro, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                ),
              ),
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
                onPressed: selectedIndex==null||selectedReasons.isEmpty?null: () async {
                  var cp = context.read<CountingProvider>();
                  var bp = context.read<BuyerProvider>();

                  var checked = await cp.saveCountingDataLocally(
                    bp,
                    from: true,
                    info: {'operationId': cp.allDefectList[selectedIndex ?? 0].operationId, 'defectId': cp.allDefectList[selectedIndex ?? 0].defectId},
                    status: getStatus(widget.form),
                  );

                  if (getStatus(widget.form) == '2' && checked) {
                    cp.alterItem();
                  } else {
                    cp.rejectItem();
                  }

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
    cp.getDefectListByOperationId('1');
  }

  String getStatus(String form) {
    return form == 'alter' ? '2' : '4';
  }
}
