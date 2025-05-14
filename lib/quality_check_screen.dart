import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nidle_qty/models/checked_enum.dart';
import 'package:nidle_qty/models/color_model.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/models/size_model.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/purchase_order.dart';
import 'package:nidle_qty/quality_report_screen.dart';
import 'package:nidle_qty/test/testing.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/alter_check.dart';
import 'package:nidle_qty/widgets/reject_alert.dart';
import 'package:nidle_qty/widgets/reset_alert.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'alteration_screen.dart';
import 'alteration_testing_screen.dart';
import 'models/send_data_model.dart';

class QualityControlScreen extends StatefulWidget {
  const QualityControlScreen({super.key});

  @override
  _QualityControlScreenState createState() => _QualityControlScreenState();
}

class _QualityControlScreenState extends State<QualityControlScreen> with WidgetsBindingObserver {
  ColorModel? _selectColor;
  SizeModel? _selectSize;
  bool showChart = false;
  bool showChartTab = false;
  String _section = '';
  String _line = '';
  List<String> alterationReasons = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
      getLunchTime();
      getPreviousCount();
      startSchedulerCallToSaveData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going to background (minimized/switched away)
      saveData();
      endSchedularSaveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quality Check'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => QualityReportScreen()));
              // var cp=context.read<CountingProvider>();
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductionReportScreen(productionData: cp.reportDataList,)));
            },
            icon: Icon(Icons.report_gmailerrorred),
          ),

          Consumer<BuyerProvider>(
            builder:
                (context, bp, _) => IconButton(
                  onPressed: () {
                    bp.lockUnlockSizeColor();
                  },
                  icon: bp.lock ? Icon(Icons.lock) : Icon(Icons.lock_open),
                ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.bar_chart),
          //   onPressed: () {
          //     if (MediaQuery.of(context).size.width > 600) {
          //       setState(() {
          //         showChartTab = !showChartTab;
          //       });
          //     } else {
          //       setState(() {
          //         showChart = !showChart;
          //       });
          //     }
          //   },
          // ),
        ],
      ),
      body: Consumer<CountingProvider>(
        builder:
            (context, ccp, _) =>
                ccp.isLoadingLunchTime
                    ? CircularProgressIndicator()
                    : ccp.isLunchTime
                    ? Center(
                      child: Text('Your Lunch time ${DashboardHelpers.formatExactLunchTime(ccp.lunchTime!.lunchStartTime ?? '', ccp.lunchTime!.lunchEndTime ?? '')}', textAlign: TextAlign.center),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<BuyerProvider>(
                            builder: (context, provider, _) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInfoRow('Buyer', provider.buyerInfo!.name),
                                              _buildInfoRow('Style', '${provider.buyerStyle!.style}'),
                                              _buildInfoRow('PO', provider.buyerPo!.po),
                                            ],
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Column(children: [_buildInfoRow('Sec:', _section), _buildInfoRow('Line', _line)])),
                                        // IconButton(
                                        //   onPressed: () {
                                        //     showResetConfirmationDialog(context, provider);
                                        //   },
                                        //   icon: Icon(Icons.lock_reset, size: 24),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Consumer<BuyerProvider>(
                                          builder:
                                              (context, pro, _) => InkWell(
                                                onTap: () {
                                                  if (pro.lock) {
                                                    DashboardHelpers.showAlert(msg: 'Please unlock to Select');
                                                  }
                                                },
                                                child: AbsorbPointer(
                                                  absorbing: pro.lock,
                                                  child: Row(
                                                    children: [
                                                      // Category Dropdown
                                                      _buildColorDropdown(
                                                        value: _selectColor,
                                                        items: pro.colorList,
                                                        hint: 'Select Color',
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              _selectColor = value;
                                                            });
                                                            //update color
                                                            pro.setBuyersStylePoInfo(color: _selectColor);
                                                            setState(() {
                                                              _selectColor = value;
                                                            });
                                                            //update color
                                                            pro.setBuyersStylePoInfo(color: _selectColor);
                                                            //check if it is similar to previous selection than count will update
                                                            if (_selectColor != null && _selectSize != null) {
                                                              //check if previous data
                                                            }
                                                          }
                                                        },
                                                      ),

                                                      const SizedBox(width: 8),
                                                      // Size Dropdown
                                                      _buildSizeDropdown(
                                                        value: _selectSize,
                                                        items: pro.sizeList,
                                                        hint: 'Size',
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              _selectSize = value;
                                                            });
                                                            pro.setBuyersStylePoInfo(size: _selectSize);
                                                            //check if it is similar to previous selection than count will update
                                                            if (_selectColor != null && _selectSize != null) {
                                                              //check if previous data
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ),
                                        SizedBox(height: 32),
                                        Consumer<CountingProvider>(
                                          builder:
                                              (context, pro, _) => Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 280,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        elevation: 4,
                                                      ),
                                                      onPressed:
                                                          _selectColor != null && _selectSize != null
                                                              ? () async {
                                                                // increment
                                                                pro.checkedItem();
                                                                var bp = context.read<BuyerProvider>();
                                                                pro.addDataToLocalList(bp, status: CheckedStatus.pass);
                                                                //need a buyer provider obj
                                                                // var bp = context.read<BuyerProvider>();
                                                                // //set counting data locally
                                                                // var checked=await pro.saveCountingDataLocally(bp,status: CheckedStatus.pass);
                                                                // if(checked){
                                                                //   pro.checkedItem();
                                                                // }
                                                              }
                                                              : null,
                                                      child: Text('PASS(${pro.checked})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 160,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              elevation: 4,
                                                            ),
                                                            onPressed:
                                                                _selectColor != null && _selectSize != null
                                                                    ? () {
                                                                      showRejectionDialog(
                                                                        context,
                                                                        onConfirm: () {
                                                                          Navigator.push(context, CupertinoPageRoute(builder: (context) => AlterationReasonScreen(form: CheckedStatus.reject)));
                                                                          // Navigator.push(context, CupertinoPageRoute(builder: (context) => QualityCheckScreen(form: CheckedStatus.reject)));
                                                                        },
                                                                      );
                                                                    }
                                                                    : null,
                                                            child: Text(
                                                              'REJECT (${pro.reject})',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 160,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.orange,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              elevation: 4,
                                                            ),
                                                            onPressed:
                                                                _selectColor != null && _selectSize != null
                                                                    ? () {
                                                                      Navigator.push(context, CupertinoPageRoute(builder: (context) => AlterationReasonScreen(form: 'alter')));
                                                                      // Navigator.push(context, CupertinoPageRoute(builder: (context) => QualityCheckScreen(form: CheckedStatus.alter)));
                                                                    }
                                                                    : null,
                                                            child: Text(
                                                              'ALTER (${pro.alter})',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 160,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.green.shade800,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              elevation: 4,
                                                            ),
                                                            onPressed: _selectColor != null && _selectSize != null ? _alter_checked : null,
                                                            child: Text(
                                                              'ALTER CHECK (${pro.alter_check})',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 60),
                                                  //saveCountingDataLocally
                                                ],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          // SizedBox(
                          //   height: 80,
                          //   child: Consumer<CountingProvider>(
                          //     builder:
                          //         (context, pro, _) => Padding(
                          //           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                          //           child: ElevatedButton(
                          //             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 4),
                          //             onPressed:
                          //                 _selectColor != null && _selectSize != null
                          //                     ? () {
                          //                       var bp = context.read<BuyerProvider>();
                          //                       pro.saveCountingDataLocally(bp);
                          //                     }
                          //                     : null,
                          //             child: Row(
                          //               mainAxisAlignment: MainAxisAlignment.center,
                          //               children: [Text('Save', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))],
                          //             ),
                          //           ),
                          //         ),
                          //   ),
                          // ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
      ),
    );
  }

  Widget _buildColorDropdown({required ColorModel? value, required List<ColorModel> items, required String hint, required Function(ColorModel?) onChanged}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ColorModel>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
            hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
            items:
                items.map((ColorModel value) {
                  return DropdownMenuItem<ColorModel>(value: value, child: Text(value.color ?? ''));
                }).toList(),
            onChanged: (val) {
              onChanged(val);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSizeDropdown({required SizeModel? value, required List<SizeModel> items, required String hint, required Function(SizeModel?) onChanged}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<SizeModel>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
            hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
            items:
                items.map((SizeModel value) {
                  return DropdownMenuItem<SizeModel>(value: value, child: Text(value.size ?? ''));
                }).toList(),
            onChanged: (val) {
              onChanged(val); // Call the parent's callback
            },
          ),
        ),
      ),
    );
  }

  _alter_checked() {
    showAlterCheckDialog(
      context,
      onConfirm: () async {
        var cp = context.read<CountingProvider>();
        var bp = context.read<BuyerProvider>();

        cp.checkedItemFromAlter();
        //save counting data locally
        await cp.addDataToLocalList(bp, status: CheckedStatus.alter_check);
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (fixed width)
        SizedBox(
          width: 50, // Adjust based on your longest label
          child: Text('$label : ', style: TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.visible),
        ),
        // Value (flexible space)
        Flexible(
          child: Text(
            value != null ? DashboardHelpers.truncateString(value, 30) : 'Not selected',
            style: TextStyle(color: Colors.blue),
            overflow: TextOverflow.ellipsis, // Handles overflow gracefully
            maxLines: 2, // Allows text to wrap
          ),
        ),
      ],
    );
  }

  Future<void> getPreviousCount() async {
    _section = await DashboardHelpers.getString('selectedSection');
    _line = await DashboardHelpers.getString('selectedLine');
    setState(() {});
  }

  void startSchedulerCallToSaveData() async {
    var cp = context.read<CountingProvider>();
    var bp = context.read<BuyerProvider>();
    cp.startPeriodicTask(bp);
  }

  void endSchedularSaveData() async {
    var cp = context.read<CountingProvider>();
    cp.stopPeriodicTask();
  }

  void saveData() async {
    var cp = context.read<CountingProvider>();
    cp.saveFullDataPeriodically();
  }

  void getLunchTime() async {
    var secId = await DashboardHelpers.getString('selectedSectionId');
    if (secId != '') {
      var cp = context.read<CountingProvider>();
      cp.getLunchTimeBySectionId(secId);
    }
  }
}
