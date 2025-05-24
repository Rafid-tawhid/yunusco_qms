import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nidle_qty/login_screen.dart';
import 'package:nidle_qty/models/checked_enum.dart';
import 'package:nidle_qty/models/color_model.dart';
import 'package:nidle_qty/models/size_model.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/quality_report_screen.dart';
import 'package:nidle_qty/utils/constants.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/alter_check.dart';
import 'package:nidle_qty/widgets/clock_widget.dart';
import 'package:nidle_qty/widgets/icon_button.dart';
import 'package:nidle_qty/widgets/operation_list.dart';
import 'package:nidle_qty/widgets/production_chart.dart';
import 'package:nidle_qty/widgets/reject_alert.dart';
import 'package:nidle_qty/widgets/saking_button.dart';
import 'package:provider/provider.dart';
import 'alteration_screen.dart';

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
  late CountingProvider _countingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      getLunchTime();
      getPreviousCount();
      startSchedulerCallToSaveData();
    });
  }

  @override
  void dispose() {
    saveData(_countingProvider);
    WidgetsBinding.instance.removeObserver(this);
    endSchedularSaveData(_countingProvider);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _countingProvider = Provider.of<CountingProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going to background (minimized/switched away)
      saveData(Provider.of<CountingProvider>(context, listen: false));
    }
    if (state == AppLifecycleState.resumed) {
      //onAppOpened(); // Called every time the app is entered from anywhere
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColors.blackMain,

      body: SafeArea(
        child: Consumer<CountingProvider>(
          builder:
              (context, ccp, _) =>
                  ccp.isLoadingLunchTime
                      ? CircularProgressIndicator()
                      : ccp.isLunchTime
                      ? Center(
                        child: Text(
                          'Your Lunch time ${DashboardHelpers.formatExactLunchTime(ccp.lunchTime!.lunchStartTime ?? '', ccp.lunchTime!.lunchEndTime ?? '')}',
                          textAlign: TextAlign.center,
                          style: customTextStyle(20, Colors.white, FontWeight.bold),
                        ),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HeaderCountingInfo(section: _section, line: _line),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                  child: Consumer<BuyerProvider>(
                                    builder:
                                        (context, pro, _) => InkWell(
                                          onTap: () {
                                            if (pro.lock) {
                                              DashboardHelpers.showAlert(msg: 'Please unlock to Select');
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: AbsorbPointer(
                                                  absorbing: pro.lock,
                                                  child: Row(
                                                    children: [
                                                      // Category Dropdown
                                                      _buildCustomDropdown(
                                                        value: _selectColor,
                                                        items: pro.colorList,
                                                        hint: 'Select Color',
                                                        itemText: (color) => color.color ?? 'Unspecified',
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              _selectColor = value;
                                                            });
                                                            //update color
                                                            pro.setBuyersStylePoInfo(color: _selectColor);
                                                          }
                                                        },
                                                      ),

                                                      const SizedBox(width: 8),
                                                      // Size Dropdown
                                                      _buildCustomDropdown(
                                                        value: _selectSize,
                                                        items: pro.sizeList,
                                                        itemText: (size) => size.size ?? 'Unspecified',
                                                        hint: 'Select Size',
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              _selectSize = value;
                                                            });
                                                            pro.setBuyersStylePoInfo(size: _selectSize);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [

                                                    RectangleIconButton(
                                                      icon: Icons.save_alt,
                                                      onPressed: () {
                                                        saveData(_countingProvider);
                                                      },
                                                      backgroundColor: myColors.blackSecond,
                                                      iconColor: Colors.white,
                                                      borderRadius: 6.0,
                                                      elevation: 4.0,
                                                      padding: const EdgeInsets.all(12),
                                                    ),
                                                    SizedBox(width: 8),
                                                    RectangleIconButton(
                                                      icon: Icons.add_chart_outlined,
                                                      onPressed: () async {
                                                        var cp = context.read<CountingProvider>();
                                                        var bp = context.read<BuyerProvider>();
                                                        await cp.getTodaysCountingData(bp);
                                                        if(cp.totalCountingModel!=null){
                                                          Navigator.push(context, CupertinoPageRoute(builder: (context) => ProductionReportScreen(stats: cp.totalCountingModel!,)));
                                                        }

                                                      },
                                                      backgroundColor: myColors.blackSecond,
                                                      iconColor: Colors.white,
                                                      borderRadius: 6.0,
                                                      elevation: 4.0,
                                                      padding: const EdgeInsets.all(12),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Consumer<BuyerProvider>(
                                                      builder:
                                                          (context, pro, _) => RectangleIconButton(
                                                            icon: pro.lock ? Icons.lock : Icons.lock_open,
                                                            onPressed: () {
                                                              pro.lockUnlockSizeColor();
                                                            },
                                                            backgroundColor: myColors.blackSecond,
                                                            iconColor: Colors.white,
                                                            borderRadius: 6.0,
                                                            elevation: 4.0,
                                                            padding: const EdgeInsets.all(12),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: Consumer<CountingProvider>(
                              builder:
                                  (context, pro, _) => Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    SizedBox.expand(
                                                      // Use SizedBox.expand to fill all available space
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                          elevation: 4,
                                                        ),
                                                        onPressed:
                                                            _selectColor != null && _selectSize != null
                                                                ? () async {
                                                                  pro.checkedItem();
                                                                  var bp = context.read<BuyerProvider>();
                                                                  pro.addDataToLocalList(bp, status: CheckedStatus.pass);
                                                                }
                                                                : null,
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white, size: 54)),
                                                            Text('PASS(${pro.checked})', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 8,
                                                      right: 8,
                                                      child: Consumer<CountingProvider>(
                                                        builder:
                                                            (context, pp, _) => Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(pp.reportDataList.length.toString(), style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                                                Icon(Icons.history, color: Colors.white, size: 24),
                                                              ],
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: MediaQuery.sizeOf(context).height / 5,
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
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.close_outlined, color: Colors.white, size: 40)),
                                                            Text('REJECT(${pro.reject})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: MediaQuery.sizeOf(context).height / 5,
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
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.change_circle_outlined, color: Colors.white, size: 40)),
                                                            Text('ALTER(${pro.alter})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: MediaQuery.sizeOf(context).height / 5,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green.shade800,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                          elevation: 4,
                                                        ),
                                                        onPressed: _selectColor != null && _selectSize != null ? _alter_checked : null,
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(padding: const EdgeInsets.all(2.0), child: Icon(Icons.recycling_outlined, color: Colors.white, size: 40)),
                                                            FittedBox(child: Text('ALTER CHECK(${pro.alter_check})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 40),
                                              //saveCountingDataLocally
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Consumer<CountingProvider>(
                                                  builder:
                                                      (context, cp, _) => Container(
                                                        width: double.infinity,
                                                        alignment: Alignment.center,
                                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                        decoration: BoxDecoration(color: myColors.blackSecond, borderRadius: BorderRadius.circular(8)),
                                                        child: Text(
                                                          '${cp.checked + cp.alter + cp.reject} | ${cp.checked} | ${cp.alter} | ${cp.reject}',
                                                          style: customTextStyle(20, Colors.white, FontWeight.bold),
                                                        ),
                                                      ),
                                                ),
                                                SizedBox(height: 12),
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(color: myColors.blackSecond, borderRadius: BorderRadius.circular(8)),
                                                  child: DualLineChart(
                                                    primaryValues: [45, 60, 75, 50, 65],
                                                    // First production line values
                                                    secondaryValues: [35, 50, 85, 40, 75],
                                                    // Second production line values
                                                    primaryColor: Colors.orange,
                                                    secondaryColor: Colors.blue,
                                                    labels: ['8', '10', '12', '14', '16'], // Day labels
                                                  ),
                                                ),
                                                if (ccp.tempDefectList.isNotEmpty) OperationsListWidget(operations: ccp.tempDefectList),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown<T>({required T? value, required List<T> items, required String Function(T) itemText, required String hint, required Function(T?) onChanged}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: myColors.blackSecond, borderRadius: BorderRadius.circular(8), border: Border.all(color: myColors.blackMain)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            hint: Text(hint, style: const TextStyle(color: Colors.white)),
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
            elevation: 4,
            items:
                items.map((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(itemText(value), style: customTextStyle(14, Colors.white, FontWeight.bold))),
                  );
                }).toList(),
            onChanged: onChanged,
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

  Future<void> getPreviousCount() async {
    _section = await DashboardHelpers.getString('selectedSection');
    _line = await DashboardHelpers.getString('selectedLine');
    //
    //if style is different from previous the count will be zero

    setState(() {});
  }

  void startSchedulerCallToSaveData() async {
    var cp = context.read<CountingProvider>();
    var bp = context.read<BuyerProvider>();
    cp.startPeriodicTask(bp);
  }

  void endSchedularSaveData(CountingProvider cp) async {
    cp.stopPeriodicTask();
  }

  void saveData(CountingProvider cp) async {
    //var cp = context.read<CountingProvider>();
    cp.saveFullDataPeriodically();
  }

  void getLunchTime() async {
    var secId = await DashboardHelpers.getString('selectedSectionId');
    if (secId != '') {
      var cp = context.read<CountingProvider>();
      var bp = context.read<BuyerProvider>();
      cp.getLunchTimeBySectionId(secId);
      //set unlock
      bp.lockUnlockSizeColor(val: false);
    }
  }

  void onAppOpened() async {
    var newDay = await DashboardHelpers.clearDataIfNewDay();
    if (newDay) {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
  }
}

class HeaderCountingInfo extends StatelessWidget {
  const HeaderCountingInfo({super.key, required String section, required String line}) : _section = section, _line = line;

  final String _section;
  final String _line;

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerProvider>(
      builder:
          (context, pro, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () {
                    //save data
                    var cp = context.read<CountingProvider>();
                    cp.saveFullDataPeriodically();

                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Text('QMS', style: customTextStyle(24, Colors.white, FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(height: 30, width: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(_section, style: customTextStyle(14, Colors.white, FontWeight.bold)), Text(_line, style: customTextStyle(14, Colors.white, FontWeight.bold))],
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: ShakingWifiDisableWidget()),
              SizedBox(width: 4),
              Consumer<CountingProvider>(
                builder:
                    (context, ccp, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lunch Time', style: customTextStyle(14, Colors.white, FontWeight.bold)),
                        if (ccp.lunchTime != null)
                          Text(
                            '${DashboardHelpers.formatExactLunchTime(ccp.lunchTime!.lunchStartTime ?? '', ccp.lunchTime!.lunchEndTime ?? '')}',
                            style: customTextStyle(14, Colors.white, FontWeight.bold),
                          ),
                      ],
                    ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(height: 30, width: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ),
              Align(
                child: CurrentTimeWidget(
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                alignment: Alignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(pro.buyerInfo!.name ?? '', style: customTextStyle(14, Colors.white, FontWeight.bold)),
                    Text(pro.buyerStyle!.style ?? '', style: customTextStyle(14, Colors.white, FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(width: 12),
            ],
          ),
    );
  }
}
