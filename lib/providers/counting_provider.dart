import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nidle_qty/models/checked_enum.dart';
import 'package:nidle_qty/models/defect_models.dart';
import 'package:nidle_qty/models/hourly_production_data_model.dart';
import 'package:nidle_qty/models/local_send_data_model.dart';
import 'package:nidle_qty/models/operation_defect_count_model.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/service_class/api_services.dart';
import 'package:http/http.dart' as http;
import '../models/difference_count_model.dart';
import '../models/lunch_time_model.dart';
import '../models/operation_model.dart';
import '../models/send_data_model.dart';
import '../models/total_counting_model.dart';
import '../service_class/hive_service_class.dart';
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

  Future<bool> checkedItemFromAlter() async {
    // alter = alter - 1;

    if(alter==alter_check||alter_check>alter){
      alter_check=alter;
      return false;
    }
    else {
      checked = checked + 1;
      alter_check = alter_check + 1;
     return true;
    }
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
    //5PK MF MINI FASH- 1217406
   // var result = await apiService.getData('api/qms/GetOperations/${buyerPo.itemId}');
    var result = await apiService.getData('api/qms/GetOperations/${buyerPo.style}');
    if (result != null) {
     _allOperations.clear();
      for (var i in result['Results']) {
       _allOperations.add(OperationModel.fromJson(i));
      }
     //selected first
     if(allOperations.isNotEmpty){
       selectedOperation(allOperations.first);
     }

    }
    notifyListeners();
  }

  List<DefectModels> _allDefectList = [];

  List<DefectModels> get allDefectList => _allDefectList;


  void getDefectListByOperationId() async {
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
        ////Testing
        // _lunchTime=LunchTimeModel.fromJson({
        //   "LunchStartTime": "2025-04-27 08:58:00",
        //   "LunchEndTime": "2025-04-27 08:59:00",
        //   "SectionId": 10,
        //   "LunchTimeId": 1,
        //   "IsActive": true
        // });
        debugPrint('LUNCH TIME ${ _lunchTime}');
        isCurrentTimeInLunchRangeFixed(_lunchTime);
        //automatic screen freezing
        //initializeLunchTimeChecker();
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


  bool isCurrentTimeInLunchRangeFixed(LunchTimeModel? lunchTimeData) {
    if (lunchTime == null) {
      return false;
    }
    try {
      // Parse the time strings (ignoring the date part)
      var startTimeStr = lunchTimeData!.lunchStartTime.toString().split(' ')[1];
      var endTimeStr = lunchTimeData.lunchEndTime.toString().split(' ')[1];

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

  //change 23 july
  int _sinkingTime = 30; // Initialize with 60 seconds
  Timer? _countdownTimer;
  int get sinkingTime=>_sinkingTime;


  void startPeriodicTask(BuyerProvider buyerPro) {
    // First stop any existing timers
    stopPeriodicTask();

    debugPrint('Starting periodic task with 30-second interval');

    // Start countdown timer (updates every second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sinkingTime--;
      debugPrint('Countdown: $_sinkingTime seconds remaining');

      if (_sinkingTime <= 0) {
        _sinkingTime = 30; // Reset counter
      }
      notifyListeners();
    });


    // Start periodic task (executes every 60 seconds)
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      debugPrint('Executing periodic task...');
      saveFullDataPeriodically();
    });
  }

  // Don't forget to cancel in dispose
  @override
  void dispose() {
    _periodicTimer?.cancel();
    _lunchTimeChecker?.cancel();
    super.dispose();
  }

  bool checkForPassOrAlterCheck(String status) {
    //return true if check and return false if alter check
    return status == CheckedStatus.pass || status == CheckedStatus.alter_check;
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

  List<Map<String, dynamic>> get reportDataList=>_reportDataList ;
  List<Map<String, dynamic>> _reportDataList = [];

  List<LocalSendDataModel> get testingreportDataList=>_testingreportDataList ;
  List<LocalSendDataModel> _testingreportDataList = [];


  //changed june 24
  //double data saved problem solved
  bool _isSaving = false;

  bool get isFreezingWhileSave=>_isSaving;

  Future<bool> saveFullDataPeriodically() async {
    // Return immediately if already saving
    if (_isSaving) {
      debugPrint('Save operation already in progress');
      return false;
    }

    try {
      _isSaving = true;

      if (_reportDataList.isNotEmpty) {
        final bool isConnected = await InternetConnectionChecker.instance.hasConnection;

        // If connected, send data to the server
        if (isConnected) {
          final apiResponse = await apiService.postData('api/qms/SaveQms', _reportDataList);
          debugPrint('Saved list length : ${_reportDataList.length}');
          if (apiResponse != null) {

            _reportDataList.clear();

            notifyListeners();
            debugPrint('Data saved successfully & cleared');
            return true; // Success
          }
          else {
            debugPrint('API request failed (null response)');
            return false; // Failed
          }
        } else {
          debugPrint('No internet connection');
          return false; // Failed
        }
      } else {
        debugPrint('No data found in _reportDataList');
        return true; // No data to save
      }
    } catch (e) {
      debugPrint('Error in saveFullDataPeriodically(): $e');
      return false; // Exception occurred
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }


  //set in july 15
  Future<void> addDataToLocalList(BuyerProvider bp, {required String status, dynamic info}) async {
    final secId = await DashboardHelpers.getString('selectedSectionId');
    final line = await DashboardHelpers.getString('selectedLineId');

    // Generate a unique timestamp with milliseconds precision
    final now = DateTime.now();
    final uniqueCreatedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T'
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';

    var sendingData = {
      "SectionId": secId,
      "LineId": line,
      "BuyerId": bp.buyerStyle!.buyerId,
      "Style": bp.buyerStyle!.style,
      "Po": bp.buyerPo!.po,
      "LunchId": _lunchTime == null ? 0 : _lunchTime!.lunchTimeId,
      "ItemId": bp.buyerPo!.itemId,
      "Status": status,
      "ColorId": bp.color!.colorId,
      "SizeId": bp.size!.sizeId,
      "OperationDetailsId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationDetailsId']}',
      "OperationId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationId']}',
      "DefectId": '${checkForPassOrAlterCheck(status) ? 0 : info!['defectId']}',
      "Quantity": 1,
      "CreatedDate": uniqueCreatedDate, // Using our custom formatted timestamp
    };

    // Check for duplicate CreatedDate before adding (just in case)
    bool isDuplicate = _reportDataList.any((item) => item['CreatedDate'] == uniqueCreatedDate);

    if (!isDuplicate) {
      if (info != null) {
        debugPrint('Coming from alter or reject.. :: operation Id : ${info['operationId']} and defect ID : ${info['defectId']}');
      }
      //change july 16 set data to temp list while saving
      if(_isSaving){

      }
      _reportDataList.add(sendingData);
      debugPrint('_reportDataList local saved list : ${_reportDataList.length}');

      // Save local data for testing
      await HiveLocalSendDataService.saveLocalSendData(LocalSendDataModel.fromJson(sendingData));

      // SAVE COUNTER DATA TO LOCAL DATABASE
      final sendData = SendDataModel(
        idNum: DashboardHelpers.userModel!.iDnum ?? '',
        passed: checked.toString(),
        reject: reject.toString(),
        alter: alter.toString(),
        alt_check: alter_check.toString(),
        buyer: bp.buyerInfo!.code.toString(),
        style: bp.buyerStyle!.style.toString(),
        po: bp.buyerPo!.po.toString(),
        color: bp.color.toString(),
        size: bp.size.toString(),
      );
      final box = Hive.box<SendDataModel>('sendDataBox');
      await box.put('sendDataKey', sendData);

      notifyListeners();
    } else {
      debugPrint('Duplicate entry detected with CreatedDate: $uniqueCreatedDate - Not added to list');
    }

    // Check every time if it is lunchtime or not
    checkLunchTime();
  }

  //change in july 15
  // Future<void> addDataToLocalList(BuyerProvider bp, {required String status,dynamic info}) async{
  //   final secId = await DashboardHelpers.getString('selectedSectionId');
  //   final line = await DashboardHelpers.getString('selectedLineId');
  //   var sendingData={
  //     "SectionId": secId,
  //     "LineId": line,
  //     "BuyerId": bp.buyerStyle!.buyerId,
  //     "Style": bp.buyerStyle!.style,
  //     "Po": bp.buyerPo!.po,
  //     "LunchId": _lunchTime == null ? 0 : _lunchTime!.lunchTimeId,
  //     "ItemId": bp.buyerPo!.itemId,
  //     "Status": status,
  //     "ColorId": bp.color!.colorId,
  //     "SizeId": bp.size!.sizeId,
  //     "OperationDetailsId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationDetailsId']}',
  //     "OperationId": '${checkForPassOrAlterCheck(status) ? 0 : info!['operationId']}',
  //     "DefectId": '${checkForPassOrAlterCheck(status) ? 0 : info!['defectId']}',
  //     "Quantity": 1,
  //     "CreatedDate": DateTime.now().toIso8601String(),
  //     //"CreatedDate": DashboardHelpers.convertDateTime(DateTime.now().toString(),pattern: 'yyyy-MM-ddTHH:mm:ss')
  //   };
  //   if (info != null) {
  //     debugPrint('Coming from alter or reject.. :: operation Id : ${info['operationId']} and defect ID : ${info['defectId']}');
  //   }
  //   _reportDataList.add(sendingData);
  //   debugPrint('_reportDataList local saved list : ${_reportDataList.length}');
  //
  //   //save local data for testing
  //   await HiveLocalSendDataService.saveLocalSendData(LocalSendDataModel.fromJson(sendingData));
  //
  //   //SAVE COUNTER DATA TO LOCAL DATABASE
  //   final sendData = SendDataModel(
  //     idNum: DashboardHelpers.userModel!.iDnum ?? '',
  //     passed: checked.toString(),
  //     reject: reject.toString(),
  //     alter: alter.toString(),
  //     alt_check: alter_check.toString(),
  //     buyer: bp.buyerInfo!.code.toString(),
  //     style: bp.buyerStyle!.style.toString(),
  //     po: bp.buyerPo!.po.toString(),
  //     color: bp.color.toString(),
  //     size: bp.size.toString(),
  //   );
  //   final box = Hive.box<SendDataModel>('sendDataBox');
  //   await box.put('sendDataKey', sendData);
  //
  //   notifyListeners();
  //
  //   //check everytime if it is lunchtime or not
  //   checkLunchTime();
  // }




  TotalCountingModel? _totalCountingModel;
  TotalCountingModel? get totalCountingModel=>_totalCountingModel;

  //
  Future<bool> getTodaysCountingData(BuyerProvider bp) async{
    //  final secId = await DashboardHelpers.getString('selectedSectionId');
    final line = await DashboardHelpers.getString('selectedLineId');

    //api/qms/GetQmsSummery
    var data = await apiService.postData('api/qms/GetQmsSummery', {
      "LineId":line,
      "BuyerId":bp.buyerInfo!.code.toString(),
      "Style":bp.buyerStyle!.style.toString(),
      "Po":bp.buyerPo!.po
    });
    if(data!=null){
      _totalCountingModel=TotalCountingModel.fromJson(data['Results'][0]);
      //changed today june 3
      //sync data auto
      if(_totalCountingModel!=null){
        checked=_totalCountingModel!.totalPass!.toInt()+_totalCountingModel!.totalAlterCheck!.toInt();
        alter=_totalCountingModel!.totalAlter!.toInt();
        alter_check=_totalCountingModel!.totalAlterCheck!.toInt();
        reject=_totalCountingModel!.totalReject!.toInt();
      }

      debugPrint('FINAL CHECKED VALUE ${checked}');
      notifyListeners();
      return true;
    }
    else {
      return false;
    }

  }


  List<HourlyProductionDataModel> _all_hourly_production_List=[];
  List<HourlyProductionDataModel> get all_hourly_production_List=>_all_hourly_production_List;

  Future<bool> getTodaysCountingDataHourDetails(BuyerProvider bp) async{
    //  final secId = await DashboardHelpers.getString('selectedSectionId');

    //api/qms/GetQmsSummery
    var data = await apiService.getData('api/Qms/QualityCheckSummary');
    if(data!=null){
      _all_hourly_production_List.clear();
      for(var i in data['Results']){
        _all_hourly_production_List.add(HourlyProductionDataModel.fromJson(i));
      }
      debugPrint('_all_hourly_production_List ${_all_hourly_production_List.length}');
      notifyListeners();
      return true;
    }
    else {
      return false;
    }

  }


  final List<Map<String,dynamic>> _tempDefectList = [];
  List<Map<String,dynamic>> get tempDefectList => _tempDefectList;
  final int _maxSize = 20;

  /// Adds a new item to the list, removing the first item if at max capacity

  void addTempDefectList(String newItem) {
    // Check if list is full and remove oldest item if needed
    if (_tempDefectList.length >= _maxSize) {
      _tempDefectList.removeAt(0);
    }

    // Check if item already exists
    final existingItem = _tempDefectList.firstWhere(
          (e) => e['item'] == newItem,
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      // Increment count if item exists
      existingItem['value']++;
    } else {
      // Add new item if it doesn't exist
      _tempDefectList.add({
        "value": 1,
        "item": newItem
      });
    }
    notifyListeners();
    //save defect data locally
    saveTempDefectList();
  }


  Future<void> saveTempDefectList() async {
    final jsonString = jsonEncode(_tempDefectList);
    DashboardHelpers.setString('tempDefectList', jsonString);
  }



  // lunch time auto checked
  Timer? _lunchTimeChecker;

  void initializeLunchTimeChecker() {
    // Cancel any existing timer
    _lunchTimeChecker?.cancel();

    // Check immediately
    checkLunchTime();

    // Then check every minute (adjust interval as needed)
    _lunchTimeChecker = Timer.periodic(const Duration(minutes: 1), (_) {
      checkLunchTime();
    });
  }

  void checkLunchTime() {
    if (lunchTime == null) {
      _isLunchTime = false;
      notifyListeners();
      return;
    }
    try {
      final now = DateTime.now();
      final todayDate = "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}";

      // Parse times (assuming format is like "HH:mm:ss")
      var startTimeStr = lunchTime!.lunchStartTime.toString().split(' ')[1];
      var endTimeStr = lunchTime!.lunchEndTime.toString().split(' ')[1];
      // startTimeStr='08:40:38';
      // endTimeStr='08:42:38';

      final lunchStart = DateTime.parse("$todayDate $startTimeStr");
      final lunchEnd = DateTime.parse("$todayDate $endTimeStr");

      final newStatus = (now.isAfter(lunchStart) || now.isAtSameMomentAs(lunchStart)) &&
          (now.isBefore(lunchEnd) || now.isAtSameMomentAs(lunchEnd));

      if (newStatus != _isLunchTime) {
        _isLunchTime = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking lunch time: $e');
      if (_isLunchTime) {
        _isLunchTime = false;
        notifyListeners();
      }
    }
  }


  List<HourlyProductionDataModel> _hourly_production_List=[];
  List<HourlyProductionDataModel> get hourly_production_List=>_hourly_production_List;

  Future<void> getHourlyProductionData(String date) async{

     var lineId = await DashboardHelpers.getString('selectedLineId');
     debugPrint('Line ID  ${lineId}');
      var data=await apiService.getData('api/Qms/QualityCheckSummary?LineNo=${lineId}&FilterDate=${date}');
      if(data!=null){
        _hourly_production_List.clear();
       for(var i in data['Results']){
         _hourly_production_List.add(HourlyProductionDataModel.fromJson(i));
       }
       debugPrint('_hourly_production_List ${_hourly_production_List.length}');
      }
      notifyListeners();
  }


  void setDefectList(List<Map<String, dynamic>> defectList) {
    _tempDefectList.clear();
    _tempDefectList.addAll(defectList);
    notifyListeners();
  }


  List<OperationDefectCountModel> _operation_defect=[];
  List<OperationDefectCountModel> get operation_defect=>_operation_defect;

  Future<void> getHourlyOperationDefects(String formattedDate) async {

    var lineId = await DashboardHelpers.getString('selectedLineId');
    debugPrint('Line ID  ${lineId}');
    var data=await apiService.getData('api/Qms/DefectSummary?LineNo=${lineId}&FilterDate=$formattedDate');
    if(data!=null){
      _operation_defect.clear();
      for(var i in data['Results']){
        _operation_defect.add(OperationDefectCountModel.fromJson(i));
      }
      debugPrint('_operation_defect ${_operation_defect.length}');
    }
    notifyListeners();
  }

  List<DifferenceCountModel> _difference_list=[];
  List<DifferenceCountModel> get difference_list=>_difference_list;
  List<double> _yesterDayPassList = List.generate(8, (index) => Random().nextDouble() * 80);
  List<double> _todayDayPassList = List.generate(8, (index) => Random().nextDouble() * 80);
  List<double> get yesterDayPassList=>_yesterDayPassList;
  List<double> get todayDayPassList=>_todayDayPassList;


  Future<void> getTwodaysDifference(String formattedDate) async {
    try {
      var lineId = await DashboardHelpers.getString('selectedLineId');
      if (lineId.isEmpty) {
        debugPrint('Line ID is empty');
        return;
      }

      var data = await apiService.getData(
        'api/Qms/QualityCheckComprasionByLine?LineNo=$lineId&FilterDate=$formattedDate',
      );

      // Clear lists before processing new data
      _difference_list.clear();
      _todayDayPassList.clear();
      _yesterDayPassList.clear();

      // Fallback to empty list if data is null or doesn't contain 'Results'
      final results = data?['Results'] as List? ?? [];

      if (results.isEmpty) {
        debugPrint('No data found in API response');
        // Optionally, set default values (e.g., zeros) if needed
        _todayDayPassList = List.filled(8, 0);
        _yesterDayPassList = List.filled(8, 0);
        notifyListeners();
        return;
      }

      // Process each item in results with null checks
      for (var item in results) {
        try {
          var model = DifferenceCountModel.fromJson(item);
          _difference_list.add(model);

          // Safely parse todayPass and yesterdayPass (fallback to 0 if null)
          _todayDayPassList.add((model.todayPass ?? 0).toDouble());
          _yesterDayPassList.add((model.yesterdayPass ?? 0).toDouble());
        } catch (e) {
          debugPrint('Error parsing item: $e');
          // Fallback to 0 if parsing fails
          _todayDayPassList.add(0);
          _yesterDayPassList.add(0);
        }
      }

      // Ensure lists have at most 8 elements (or pad with 0 if needed)
      _todayDayPassList = _todayDayPassList.take(8).toList();
      _yesterDayPassList = _yesterDayPassList.take(8).toList();

      // If lists are shorter than 8, pad with zeros (optional)
      if (_todayDayPassList.length < 8) {
        _todayDayPassList.addAll(List.filled(8 - _todayDayPassList.length, 0));
      }
      if (_yesterDayPassList.length < 8) {
        _yesterDayPassList.addAll(List.filled(8 - _yesterDayPassList.length, 0));
      }

      notifyListeners();
      debugPrint('_difference_list ${_difference_list.length}');
      debugPrint('_todayDayPassList $_todayDayPassList');
      debugPrint('_yesterDayPassList $_yesterDayPassList');
    } catch (e) {
      debugPrint('Error in getTwodaysDifference: $e');
      // Fallback to default values on error
      _todayDayPassList = List.filled(8, 0);
      _yesterDayPassList = List.filled(8, 0);
      notifyListeners();
    }
  }

}
