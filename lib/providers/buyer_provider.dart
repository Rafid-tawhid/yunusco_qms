import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:nidle_qty/models/po_models.dart';
import 'package:nidle_qty/models/size_model.dart';
import 'package:nidle_qty/models/user_model.dart';
import 'package:nidle_qty/service_class/api_services.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import '../models/buyer_model.dart';
import '../models/buyer_style_model.dart';
import '../models/color_model.dart';

class BuyerProvider extends ChangeNotifier {
  bool _loadingStyle = false;
  bool _loadingBuyer = false;
  bool _loadingPurchase = false;
  ApiService apiService = ApiService();

  bool get loadingStyle => _loadingStyle;

  setLoadingStyle(bool val) {
    _loadingStyle = val;
    notifyListeners();
  }

  setLoadingPo(bool val) {
    _loadingPurchase = val;
    notifyListeners();
  }

  bool get loadingPurchase => _loadingPurchase;

  Future<bool> userLogin(String email, String pass) async {
    debugPrint('Email : $email and Pass : ${pass}');
    var result = await apiService.postData('api/Accounts/GetUserLogin', {'username': email, 'password': pass});
    if (result != null) {
      DashboardHelpers.setToken(result['token']);

      // 1. First convert your API response to UserModel
      final userData = result['returnvalue']['login'];
      UserModel _user = UserModel.fromJson(userData);

      // 2. Then store the serialized version
      DashboardHelpers.setString('user', jsonEncode(_user.toJson()));

      DashboardHelpers.setUserInfo();
      return true;
    } else {
      return false;
    }
  }

  final List<BuyerModel> _allBuyers = [];
  List<BuyerModel> _filteredBuyers = [];

  List<BuyerModel> get allBuyers => _allBuyers;

  List<BuyerModel> get filteredBuyers => _filteredBuyers;

  bool get loadingBuyer => _loadingBuyer;

  Future<bool> getAllBuyerList() async {
    var data = await apiService.getData('api/qms/AllBuyer');
    if (data != null) {
      _allBuyers.clear();
      _filteredBuyers.clear();
      for (var i in data['Results']) {
        _allBuyers.add(BuyerModel.fromJson(i));
      }
      _filteredBuyers.addAll(_allBuyers);
      debugPrint('_allBuyers ${_allBuyers.length}');
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  setLoadingBuyer(bool val) {
    _loadingBuyer = val;
    notifyListeners();
  }

  void searchInBuyerList(String query) {
    if (query.isEmpty) {
      // If search query is empty, restore original list
      _filteredBuyers = List.from(_allBuyers);
    } else {
      // Filter the list based on search query
      _filteredBuyers =
          _allBuyers.where((item) {
            // Convert all comparisons to lowercase for case-insensitive search
            final searchLower = query.toLowerCase();
            // Search in all relevant fields
            return (item.name?.toLowerCase().contains(searchLower) ?? false);
          }).toList();
    }

    notifyListeners();
  }

  void searchInStyleList(String query) {
    if (query.isEmpty) {
      // If search query is empty, restore original list
      _filteredBuyerStyleList = List.from(_buyerStyleList);
    } else {
      // Filter the list based on search query
      _filteredBuyerStyleList =
          _buyerStyleList.where((item) {
            // Convert all comparisons to lowercase for case-insensitive search
            final searchLower = query.toLowerCase();
            // Search in all relevant fields
            return (item.style.toString().toLowerCase().contains(searchLower) ?? false);
          }).toList();
    }

    notifyListeners();
  }

  void searchPurchaseOrderList(String query) {
    if (query.isEmpty) {
      // If search query is empty, restore original list
      _filteredPoListByStyle = List.from(_poListByStyle);
    } else {
      // Filter the list based on search query
      _filteredPoListByStyle =
          _poListByStyle.where((item) {
            // Convert all comparisons to lowercase for case-insensitive search
            final searchLower = query.toLowerCase();
            // Search in all relevant fields
            return (item.po.toString().toLowerCase().contains(searchLower) ?? false);
          }).toList();
    }

    notifyListeners();
  }

  List<BuyerStyleModel> _buyerStyleList = [];

  List<BuyerStyleModel> get buyerStyleList => _buyerStyleList;

  List<BuyerStyleModel> _filteredBuyerStyleList = [];

  List<BuyerStyleModel> get filteredStyleList => _filteredBuyerStyleList;

  Future<bool> getStyleDataByBuyerId(String id) async {
    var data = await apiService.getData('api/qms/BuyerwiseStyle/$id');
    if (data != null) {
      _buyerStyleList.clear();
      _filteredBuyerStyleList.clear();
      for (var i in data['Results']) {
        _buyerStyleList.add(BuyerStyleModel.fromJson(i));
      }
      _filteredBuyerStyleList.addAll(_buyerStyleList);
      debugPrint('_buyerStyleList ${_buyerStyleList.length}');
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  List<PoModels> _poListByStyle = [];

  List<PoModels> get poListByStyle => _poListByStyle;

  List<PoModels> _filteredPoListByStyle = [];

  List<PoModels> get filteredPoListByStyle => _filteredPoListByStyle;

  Future<void> getBoByStyleOfBuyers(String styleName) async {
    var data = await apiService.getData('api/qms/StyleWisePO/${styleName}');
    if (data != null) {
      _poListByStyle.clear();
      _filteredPoListByStyle.clear();
      for (var i in data['Results']) {
        _poListByStyle.add(PoModels.fromJson(i));
      }
      _filteredPoListByStyle.addAll(_poListByStyle);
      debugPrint('_filteredPoListByStyle ${_filteredPoListByStyle.length}');
      notifyListeners();
    }
  }

  BuyerModel? _buyerInfo;
  BuyerStyleModel? _buyerStyle;
  PoModels? _buyerPo;
  ColorModel? _color;
  SizeModel? _size;

  // Getters
  BuyerModel? get buyerInfo => _buyerInfo;

  BuyerStyleModel? get buyerStyle => _buyerStyle;

  PoModels? get buyerPo => _buyerPo;

  ColorModel? get color => _color;

  SizeModel? get size => _size;

  Future<void> setBuyersStylePoInfo({BuyerModel? buyerInfo, BuyerStyleModel? buyerStyle, PoModels? buyerPO, ColorModel? color, SizeModel? size}) async {
    // Update only the provided values
    if (buyerInfo != null) _buyerInfo = buyerInfo;
    if (buyerStyle != null) _buyerStyle = buyerStyle;
    if (buyerPO != null) _buyerPo = buyerPO;
    if (color != null) _color = color;
    if (size != null) _size = size;

    // Print all current values
    debugPrint('''
  ====== Current Values ======
  Buyer Info: ${_buyerInfo?.name.toString()}
  Buyer Style: ${_buyerStyle?.style.toString()}
  Buyer PO: ${_buyerPo?.po.toString()}
  Color: ${_color == null ? null : _color!.toJson()}
  Size: ${_size == null ? null : _size!.toJson()}
  ===========================
  ''');

    notifyListeners();
  }

  void clearStyleAndPoList() {
    _filteredPoListByStyle.clear();
    _poListByStyle.clear();
    _buyerPo = null;
    _buyerStyle = null;
    notifyListeners();
  }

  List<ColorModel> _colorList = [];

  List<ColorModel> get colorList => _colorList;

  Future<void> getColor(String? buyerPo) async {
    var data = await apiService.getData('api/qms/GetColors/$buyerPo');
    if (data != null) {
      _colorList.clear();
      for (var i in data['Results']) {
        _colorList.add(ColorModel.fromJson(i));
      }
      debugPrint('_colorList ${_colorList.length}');
      notifyListeners();
    }
  }

  List<SizeModel> _sizeList = [];

  List<SizeModel> get sizeList => _sizeList;

  Future<void> getSize(String? buyerPo) async {
    var data = await apiService.getData('api/qms/GetSizes/$buyerPo');
    if (data != null) {
      _sizeList.clear();
      for (var i in data['Results']) {
        _sizeList.add(SizeModel.fromJson(i));
      }
      debugPrint('_sizeList ${_sizeList.length}');
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _allSections = [];

  List<Map<String, dynamic>> get allSection => _allSections;

  void getAllSections() async {
    var data = await apiService.getData('api/qms/GetSections');
    if (data != null) {
      _allSections.clear();
      for (var i in data['Results']) {
        _allSections.add(i);
      }
      debugPrint('_allSections ${_allSections.length}');
      notifyListeners();
    }
  }

  //
  //

  bool _lock = false;

  bool get lock => _lock;

  void lockUnlockSizeColor() {
    _lock = !_lock;
    notifyListeners();
  }

  List<Map<String, dynamic>> _allLines = [];

  List<Map<String, dynamic>> get allLines => _allLines;

  Future<void> getAllLinesBySectionId(String sectionId) async {
    var data = await apiService.getData('api/qms/GetLines/$sectionId');
    if (data != null) {
      _allLines.clear();
      for (var i in data['Results']) {
        _allLines.add(i);
      }
      debugPrint('_allLines ${_allLines.length}');
      notifyListeners();
    }
  }
}
