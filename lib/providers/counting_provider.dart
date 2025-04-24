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
    var result = await apiService.getData('api/PreSalesApi/GetOperations?itemId=${buyerPo.itemId}');
    if (result != null) {
      _allOperations.clear();
      for (var i in result['returnvalue']) {
        _allOperations.add(i);
      }
    }
    notifyListeners();
  }

  List<DefectModels> _allDefectList = [];

  List<DefectModels> get allDefectList => _allDefectList;

  void getDefectListByOperationId(String id) async {
    var result = await apiService.getData(
      'api/PreSalesApi/GetDefects?OperationId=$id',
    );
    if (result != null) {
      _allDefectList.clear();
      for (var i in result['returnvalue']) {
        _allDefectList.add(DefectModels.fromJson(i));
      }
    }
    debugPrint('_allDefectList ${_allDefectList.length}');
    notifyListeners();
  }

  void resetAllCount() {
    checked = 0;
    reject = 0;
    alter = 0;
    alter_check = 0;
    notifyListeners();
  }

  void setPreviousValue(SendDataModel savedData) {
    checked = int.parse(savedData.passed);
    reject = int.parse(savedData.reject);
    alter = int.parse(savedData.alter);
    alter_check = int.parse(savedData.alt_check);
    notifyListeners();
  }


  Future<void> saveCountingDataLocally(BuyerProvider buyerPro) async {
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
    //save data to sync
    final box = Hive.box<SendDataModel>('sendDataBox');
    await box.put('sendDataKey', sendData);
    debugPrint('Saved All Info: ${sendData.toJson()}');
  }

  Future<SendDataModel?> getCountingDataLocally() async {
    try {
      final box = Hive.box<SendDataModel>('sendDataBox');
      final sendData = box.get('sendDataKey');

      if (sendData != null) {
        debugPrint('Retrieved Data: ${sendData.toJson()}');
        checked=int.parse(sendData.passed);
        reject=int.parse(sendData.reject);
        alter=int.parse(sendData.alter);
        alter_check=int.parse(sendData.alt_check);
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

  // Start the timer when needed
  void startPeriodicTask(BuyerProvider buyerPro) {
    _periodicTimer?.cancel(); // Cancel existing timer if any
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 5), // Runs every 2 minutes
          (timer) => saveCountingDataLocally(buyerPro),
    );
  }

  // Cancel the timer when not needed (e.g., when user logs out)
  void stopPeriodicTask() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

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




