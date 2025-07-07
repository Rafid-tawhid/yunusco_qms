class HourlyProductionDataModel {
  HourlyProductionDataModel({
      String? timeRange, 
      num? lineId, 
      num? buyerId, 
      String? buyerName, 
      String? po, 
      String? style, 
      num? pass, 
      num? alteration, 
      num? alterCheck, 
      num? reject, 
      num? totalRecords,}){
    _timeRange = timeRange;
    _lineId = lineId;
    _buyerId = buyerId;
    _buyerName = buyerName;
    _po = po;
    _style = style;
    _pass = pass;
    _alteration = alteration;
    _alterCheck = alterCheck;
    _reject = reject;
    _totalRecords = totalRecords;
}

  HourlyProductionDataModel.fromJson(dynamic json) {
    _timeRange = json['TimeRange'];
    _lineId = json['LineId'];
    _buyerId = json['BuyerId'];
    _buyerName = json['BuyerName'];
    _po = json['PO'];
    _style = json['Style'];
    _pass = json['Pass'];
    _alteration = json['Alteration'];
    _alterCheck = json['AlterCheck'];
    _reject = json['Reject'];
    _totalRecords = json['TotalRecords'];
  }
  String? _timeRange;
  num? _lineId;
  num? _buyerId;
  String? _buyerName;
  String? _po;
  String? _style;
  num? _pass;
  num? _alteration;
  num? _alterCheck;
  num? _reject;
  num? _totalRecords;
HourlyProductionDataModel copyWith({  String? timeRange,
  num? lineId,
  num? buyerId,
  String? buyerName,
  String? po,
  String? style,
  num? pass,
  num? alteration,
  num? alterCheck,
  num? reject,
  num? totalRecords,
}) => HourlyProductionDataModel(  timeRange: timeRange ?? _timeRange,
  lineId: lineId ?? _lineId,
  buyerId: buyerId ?? _buyerId,
  buyerName: buyerName ?? _buyerName,
  po: po ?? _po,
  style: style ?? _style,
  pass: pass ?? _pass,
  alteration: alteration ?? _alteration,
  alterCheck: alterCheck ?? _alterCheck,
  reject: reject ?? _reject,
  totalRecords: totalRecords ?? _totalRecords,
);
  String? get timeRange => _timeRange;
  num? get lineId => _lineId;
  num? get buyerId => _buyerId;
  String? get buyerName => _buyerName;
  String? get po => _po;
  String? get style => _style;
  num? get pass => _pass;
  num? get alteration => _alteration;
  num? get alterCheck => _alterCheck;
  num? get reject => _reject;
  num? get totalRecords => _totalRecords;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['TimeRange'] = _timeRange;
    map['LineId'] = _lineId;
    map['BuyerId'] = _buyerId;
    map['BuyerName'] = _buyerName;
    map['PO'] = _po;
    map['Style'] = _style;
    map['Pass'] = _pass;
    map['Alteration'] = _alteration;
    map['AlterCheck'] = _alterCheck;
    map['Reject'] = _reject;
    map['TotalRecords'] = _totalRecords;
    return map;
  }

}