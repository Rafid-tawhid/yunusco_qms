import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nidle_qty/models/checked_enum.dart';
import 'package:nidle_qty/models/defect_models.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/service_class/api_services.dart';

import '../models/firebase_data_model.dart';
import '../models/lunch_time_model.dart';
import '../models/operation_model.dart';
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

  List<OperationModel> _allOperations = [];

  List<OperationModel> get allOperations => _allOperations;

  Future<void> getAllOperations({required PoModels buyerPo}) async {
   // var result = await apiService.getData('api/qms/GetOperations/${buyerPo.itemId}');
    var result = await apiService.getData('api/qms/GetOperations/5PK MF MINI FASH- 1217406');
    if (result != null) {
     _allOperations.clear();
      for (var i in result['Results']) {
       _allOperations.add(OperationModel.fromJson(i));
      }
    }
    notifyListeners();
  }

  List<DefectModels> _allDefectList = [];

  List<DefectModels> get allDefectList => _allDefectList;


  void getDefectListByOperationId(String id) async {
    var result = await apiService.getData('api/qms/GetDefects');
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
  LunchTimeModel? _lunchTime;

  bool get isLoadingLunchTime => _isLoadingLunchTime;

  LunchTimeModel? get lunchTime => _lunchTime;

  Future<void> getLunchTimeBySectionId(String secId) async {
    _isLoadingLunchTime = true;
    notifyListeners();

    try {
      final result = await apiService.getData('api/qms/GetLunchTime/$secId');

      if (result != null) {
        _lunchTime = LunchTimeModel.fromJson(result['Results'][0]);
        isCurrentTimeInLunchRangeFixed(_lunchTime); // Your existing check
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

  bool isCurrentTimeInLunchRangeFixed(LunchTimeModel? lunchTimeData) {
    if (lunchTime == null) {
      return false;
    }
    try {
      // Parse the time strings (ignoring the date part)
      final startTimeStr = lunchTimeData!.lunchStartTime.toString().split(' ')[1];
      final endTimeStr = lunchTimeData.lunchEndTime.toString().split(' ')[1];

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

  List<Map<String, dynamic>> get reportDataList=>_reportDataList ;
  List<Map<String, dynamic>> _reportDataList = [];


  Future<bool> saveCountingDataLocally(BuyerProvider buyerPro, {bool? from, Map<String, dynamic>? info, required String status}) async {
    debugPrint('THIS REQUEST IS FOR NO ${status}');

    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      // Get section and line IDs
      final secId = await DashboardHelpers.getString('selectedSectionId');
      final line = await DashboardHelpers.getString('selectedLineId');

      // Create data model
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
        size: buyerPro.size.toString(),
      );

      //todo Prepare data for API
      // final sendingData = {
      //   "QmsMasterModel": {
      //     "SectionId": secId,
      //     "LineId": line,
      //     "BuyerId": buyerPro.buyerStyle!.buyerId,
      //     "Style": buyerPro.buyerStyle!.style,
      //     "PO": buyerPro.buyerPo!.po,
      //     "LunchId": _lunchTime == null ? null : _lunchTime!.lunchTimeId,
      //     "ItemId": buyerPro.buyerPo!.itemId,
      //     "Status": status,
      //     "SizeId": buyerPro.size!.sizeId,
      //     "ColorId": buyerPro.color!.colorId,
      //   },
      //   "QmsDetailModel": [
      //     {"Status": status,
      //       "Quantity": 1,
      //       "OperationId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationId']}',
      //       "DefectId": '${checkForPassOrAlterCheck(status) ? 0 : info!['defectId']}',
      //       "SizeId": buyerPro.size!.sizeId,
      //       "ColorId": buyerPro.color!.colorId,
      //     }
      //   ],
      // };


      var sendingData={
        "SectionId": secId,
        "LineId": line,
        "BuyerId": buyerPro.buyerStyle!.buyerId,
        "Style": buyerPro.buyerStyle!.style,
        "Po": buyerPro.buyerPo!.po,
        "LunchId": _lunchTime == null ? null : _lunchTime!.lunchTimeId,
        "ItemId": buyerPro.buyerPo!.itemId,
        "Status": status,
        "ColorId": buyerPro.color!.colorId,
        "SizeId": buyerPro.size!.sizeId,
        "OperationDetailsId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationDetailsId']}',
        "OperationId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationId']}',
        "DefectId": '${checkForPassOrAlterCheck(status) ? 0 : info!['defectId']}',
        "Quantity": 1
      };

      if (info != null) {
        debugPrint('Coming from alter or reject.. :: operation Id : ${info['operationId']} and defect ID : ${info['defectId']}');
      }

      // Send data to API
      final apiResponse = await apiService.postData('api/qms/SaveQms', sendingData);
      if (apiResponse == null) {
        return false;
      }

      // Save data locally
      sendData.sent = false;
      final box = Hive.box<SendDataModel>('sendDataBox');
      await box.put('sendDataKey', sendData);

      // Prepare data for local storage
      // final localData = {
      //   'count': sendingData,
      //   'secId': secId,
      //   'line': line,
      //   'quality': from == true ? info!['operation'] : null,
      //   'reasons': from == true ? info!['reasons'] : null,
      //   'time': DateTime.now().toString(),
      // };
     // savarMainDataLocallyWithoutInternet(localData);

      return true;
    } catch (e) {
      debugPrint('Error in saveCountingDataLocally: $e');
      return false;
    }
    finally{
      EasyLoading.dismiss();
    }
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
      //saveCountingDataLocally(buyerPro);
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

  bool checkForPassOrAlterCheck(String status) {
    //return true if check and return false if alter check
    return status == CheckedStatus.pass || status == CheckedStatus.alter_check;
  }

  Future<void> savarMainDataLocallyWithoutInternet(Map<String, dynamic> localData) async {
    if(_reportDataList.length>10){
      final bool isConnected = await InternetConnectionChecker.instance.hasConnection;
      //send to save data in server
      if(isConnected){
        var send = await apiService.sendTesting(localData);
        if(send){
          debugPrint('Data is cleared');
          _reportDataList.clear();
          notifyListeners();
        }
        else {
          debugPrint('FROM THIS 1');
          _reportDataList.add(localData);
        }
      }
      else {
        debugPrint('FROM THIS 2');
        _reportDataList.add(localData);
      }
    }
    else {
      debugPrint('FROM THIS 3');
      _reportDataList.add(localData);
    }

    debugPrint('_reportDataList ${_reportDataList.length}');
  }

  OperationModel? operation;
  void selectedOperation(OperationModel data) {
    operation=data;
    notifyListeners();
  }

  List<Map<String, dynamic>> finalOperationDefectList = [];

  void setDefectReasons(List<String> selectedReasons) {
    // Check if an operation with this ID already exists
    final existingIndex = finalOperationDefectList.indexWhere(
          (item) => item["id"] == operation!.operationId,
    );

    if (existingIndex >= 0) {
      // Operation exists - update its defects
      final existingDefects = finalOperationDefectList[existingIndex]["defects"] as List<String>;

      // Add new defects that aren't already present (avoid duplicates)
      for (final reason in selectedReasons) {
        if (!existingDefects.contains(reason)) {
          existingDefects.add(reason);
        }
      }

      // Update the entry
      finalOperationDefectList[existingIndex] = {
        "id": operation!.operationId,
        "operation": operation!.operationName,
        "defects": existingDefects,
      };
    } else {
      // Operation doesn't exist - add new entry
      finalOperationDefectList.add({
        "id": operation!.operationId,
        "operation": operation!.operationName,
        "defects": selectedReasons,
      });
    }

    debugPrint('finalOperationDefectList $finalOperationDefectList');
  }



}
