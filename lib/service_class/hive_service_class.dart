import 'package:hive_flutter/hive_flutter.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import '../models/local_send_data_model.dart';
import '../models/send_data_model.dart';


class HiveLocalSendDataService {
  static const String _boxName = 'localSendDataBox';
  static const String _listKey = 'localSendDataList';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SendDataModelAdapter());
    await Hive.openBox<SendDataModel>('sendDataBox');
    Hive.registerAdapter(LocalSendDataModelAdapter());
    await Hive.openBox(_boxName);
  }

  // Modified to accept single object
  static Future<void> saveLocalSendData(LocalSendDataModel data) async {
    final box = Hive.box(_boxName);

    // Get existing list or create new if none exists
    List<LocalSendDataModel> currentList = box.get(_listKey)?.cast<LocalSendDataModel>() ?? [];

    // Add new object to the list
    currentList.add(data);

    // Save updated list back to Hive
    await box.put(_listKey, currentList);
  }

  // Keep the retrieval function the same
  static List<LocalSendDataModel>? getLocalSendDataList() {
    final box = Hive.box(_boxName);
    return box.get(_listKey)?.cast<LocalSendDataModel>();
  }

  static Future<void> clearLocalSendData() async {
    final box = Hive.box(_boxName);
    await box.delete(_listKey);
    await box.clear();
    final box2 = Hive.box<SendDataModel>('sendDataBox');
    await box2.clear();
    DashboardHelpers.removeString('tempDefectList');
  }
}