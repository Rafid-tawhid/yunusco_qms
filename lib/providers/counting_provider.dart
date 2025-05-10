import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:nidle_qty/models/defect_models.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/service_class/api_services.dart';

import '../models/send_data_model.dart';
import '../utils/dashboard_helpers.dart';

class CountingProvider with ChangeNotifier {
  ApiService apiService = ApiService();
  int checked = 0;
  int reject = 0;
  int alter = 0;
  int alter_check = 0;

  /// Returns 0 if the input is negative, otherwise returns the input value
  int nonNegative(int value) {
    return value < 0 ? 0 : value;
  }

  Future<void> checkedItem() async {
    checked = checked + 1;
    notifyListeners();
  }

  Future<void> rejectItem() async {
    reject = reject + 1;
    notifyListeners();
  }

  Future<void> alterItem() async {
    alter = alter + 1;
    notifyListeners();
  }

  Future<void> checkedItemFromAlter() async {
    alter = alter - 1;
    checked = checked + 1;
    alter_check = alter_check + 1;
    notifyListeners();
  }

  num ensureNonNegative(num number) {
    return number < 0 ? 0 : number;
  }

  Future<void> sendCountingData(SendDataModel send_data) async {
    debugPrint('send_data : $send_data');
  }

  List<Map<String, dynamic>> _allOperations = [];

  List<Map<String, dynamic>> get allOperations => _allOperations;

  void getAllOperations({required PoModels buyerPo}) async {
    var result = await apiService.getData('api/qms/GetOperations/${buyerPo.itemId}');
    if (result != null) {
      _allOperations.clear();
      for (var i in result['Results']) {
        _allOperations.add(i);
      }
    }
    notifyListeners();
  }

  List<DefectModels> _allDefectList = [];

  List<DefectModels> get allDefectList => _allDefectList;

  void getDefectListByOperationId(String id) async {
    var result = await apiService.getData('api/qms/GetDefects/$id');
    if (result != null) {
      _allDefectList.clear();
      for (var i in result['Results']) {
        _allDefectList.add(DefectModels.fromJson(i));
      }
    }
    debugPrint('_allDefectList ${_allDefectList.length}');
    notifyListeners();
  }

  bool _isLoadingLunchTime = false;
  Map<String, dynamic>? _lunchTime;

  bool get isLoadingLunchTime => _isLoadingLunchTime;

  Map<String, dynamic>? get lunchTime => _lunchTime;

  Future<void> getLunchTimeBySectionId(String secId) async {
    _isLoadingLunchTime = true;
    notifyListeners();

    try {
      final result = await apiService.getData('api/qms/GetLunchTime/10');

      if (result != null) {
        _lunchTime = result['Results'][0];

        isCurrentTimeInLunchRangeFixed(_lunchTime!); // Your existing check
      }
    } catch (e) {
      debugPrint('Error fetching lunch time: $e');
    } finally {
      _isLoadingLunchTime = false;
      notifyListeners();
    }
  }

  bool _isLunchTime = false;

  bool get isLunchTime => _isLunchTime;

  bool isCurrentTimeInLunchRange(Map<String, dynamic> lunchTimeData) {
    try {
      // Parse the input times
      final lunchStart = DateTime.parse(lunchTimeData['lunchStartTime'].toString());
      final lunchEnd = DateTime.parse(lunchTimeData['lunchEndTime'].toString());
      final currentTime = DateTime.now();

      // Compare with current time (ignoring milliseconds)
      _isLunchTime = (currentTime.isAfter(lunchStart) || currentTime.isAtSameMomentAs(lunchStart)) && (currentTime.isBefore(lunchEnd) || currentTime.isAtSameMomentAs(lunchEnd));
      notifyListeners();
      return _isLunchTime;
    } catch (e) {
      print('Error parsing time: $e');
      return false;
    }
  }

  bool isCurrentTimeInLunchRangeFixed(Map<String, dynamic> lunchTimeData) {
    try {
      // Parse the time strings (ignoring the date part)
      final startTimeStr = lunchTimeData['lunchStartTime'].toString().split(' ')[1];
      final endTimeStr = lunchTimeData['lunchEndTime'].toString().split(' ')[1];

      debugPrint('startTimeStr $startTimeStr');
      debugPrint('endTimeStr $endTimeStr');

      // Get current date components
      final now = DateTime.now();
      final todayDate =
          "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}";

      // Convert to DateTime objects (using today's date)
      final lunchStart = DateTime.parse("$todayDate $startTimeStr");
      final lunchEnd = DateTime.parse("$todayDate $endTimeStr");
      final currentTime = DateTime.now();

      // Compare only the time components
      _isLunchTime = (currentTime.isAfter(lunchStart) || currentTime.isAtSameMomentAs(lunchStart)) && (currentTime.isBefore(lunchEnd) || currentTime.isAtSameMomentAs(lunchEnd));
      notifyListeners();
      return _isLunchTime;
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return false;
    }
  }

  void resetAllCount() {
    checked = 0;
    reject = 0;
    alter = 0;
    alter_check = 0;
    notifyListeners();
  }


  List<Map<String,dynamic>> reportDataList=[];



  Future<void> saveCountingDataLocally(BuyerProvider buyerPro, {bool? from, Map<String,dynamic>? info}) async {
    final sendData = SendDataModel(
      idNum: DashboardHelpers.userModel!.iDnum ?? '',
      passed: checked.toString(),
      reject: reject.toString(),
      alter: alter.toString(),
      alt_check: alter_check.toString(),
      buyer: buyerPro.buyerInfo!.code.toString(),
      style: buyerPro.buyerStyle!.style.toString(),
      po: buyerPro.buyerPo!.po.toString(),
      color: buyerPro.color.toString(),
      size: buyerPro.size.toString(),);
    var secId=await DashboardHelpers.getString('section');
    var line=await DashboardHelpers.getString('line');
    //save data to sync

    var data={
      'count':sendData.toJson(),
       'secId':secId,
       'line': line,
       'quality': from==true?info!['operation']:null,
       'reasons': from==true?info!['reasons']:null,
        'time':DateTime.now().toString()
    };

    //if data send successful than set true
    sendData.sent=false;
    final box = Hive.box<SendDataModel>('sendDataBox');
    await box.put('sendDataKey', sendData);
    reportDataList.add(data);
    debugPrint('Saved All Info: ${data}');
  }



  Future<SendDataModel?> getCountingDataLocally() async {
    try {
      final box = Hive.box<SendDataModel>('sendDataBox');
      final sendData = box.get('sendDataKey');

      if (sendData != null) {
        debugPrint('Retrieved Data: ${sendData.toJson()}');
        checked = int.parse(sendData.passed);
        reject = int.parse(sendData.reject);
        alter = int.parse(sendData.alter);
        alter_check = int.parse(sendData.alt_check);
        notifyListeners();
        return sendData;
      } else {
        debugPrint('No data found in local storage');
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving data: $e');
      return null;
    }
  }

  Timer? _periodicTimer;

  // Function to stop the periodic task
  void stopPeriodicTask() {
    if (_periodicTimer != null) {
      _periodicTimer!.cancel();
      _periodicTimer = null;
      debugPrint('Periodic task stopped');
    } else {
      debugPrint('No periodic task running to stop');
    }
  }

  // Improved version of your start function with safety checks
  void startPeriodicTask(BuyerProvider buyerPro) {
    // First stop any existing timer
    stopPeriodicTask();

    debugPrint('Starting periodic task with 5-second interval');

    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      debugPrint('Executing periodic task...');
      saveCountingDataLocally(buyerPro);
    });
  }

  // Usage example:
  // To start: startPeriodicTask(myBuyerProvider);
  // To stop: stopPeriodicTask();

  // Don't forget to cancel in dispose
  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  // bool isBuyerInfoSame({
  //   required String code,
  //   required String style,
  //   required String po,
  //   required String color,
  //   required String size,
  // }) {
  //   final box = Hive.box<BuyerInfoModel>('buyerInfoBox');
  //   final savedInfo = box.get('buyerInfo');
  //
  //   if (savedInfo == null) return false;
  //   debugPrint('Previously SavedInfo ${savedInfo.toJson()}');
  //   debugPrint(
  //     'item to compare = code: ${code}, style: ${style}, po: ${po},color: ${color}, size:${size} )}',
  //   );
  //
  //   return savedInfo.code == code &&
  //       savedInfo.style == style &&
  //       savedInfo.po == po &&
  //       savedInfo.color == color &&
  //       savedInfo.size == size;
  // }
}
