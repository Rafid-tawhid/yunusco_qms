class DifferenceCountModel {
  DifferenceCountModel({
      String? timeRange, 
      num? lineId, 
      num? buyerId, 
      String? buyerName, 
      String? po, 
      String? style, 
      num? todayPass, 
      num? yesterdayPass, 
      num? passDiffrence, 
      num? todayAlteration, 
      num? yesterdayAlteration, 
      num? alterationDifference, 
      num? todayAlterCheck, 
      num? yesterdayAlterCheck, 
      num? alterCheckDifference, 
      num? todayReject, 
      num? yesterdayReject, 
      num? rejectDifference, 
      num? todayTotal, 
      num? yesterdayTotal, 
      num? totalDifference,}){
    _timeRange = timeRange;
    _lineId = lineId;
    _buyerId = buyerId;
    _buyerName = buyerName;
    _po = po;
    _style = style;
    _todayPass = todayPass;
    _yesterdayPass = yesterdayPass;
    _passDiffrence = passDiffrence;
    _todayAlteration = todayAlteration;
    _yesterdayAlteration = yesterdayAlteration;
    _alterationDifference = alterationDifference;
    _todayAlterCheck = todayAlterCheck;
    _yesterdayAlterCheck = yesterdayAlterCheck;
    _alterCheckDifference = alterCheckDifference;
    _todayReject = todayReject;
    _yesterdayReject = yesterdayReject;
    _rejectDifference = rejectDifference;
    _todayTotal = todayTotal;
    _yesterdayTotal = yesterdayTotal;
    _totalDifference = totalDifference;
}

  DifferenceCountModel.fromJson(dynamic json) {
    _timeRange = json['TimeRange'];
    _lineId = json['LineId'];
    _buyerId = json['BuyerId'];
    _buyerName = json['BuyerName'];
    _po = json['PO'];
    _style = json['Style'];
    _todayPass = json['TodayPass'];
    _yesterdayPass = json['YesterdayPass'];
    _passDiffrence = json['PassDiffrence'];
    _todayAlteration = json['TodayAlteration'];
    _yesterdayAlteration = json['YesterdayAlteration'];
    _alterationDifference = json['AlterationDifference'];
    _todayAlterCheck = json['TodayAlterCheck'];
    _yesterdayAlterCheck = json['YesterdayAlterCheck'];
    _alterCheckDifference = json['AlterCheckDifference'];
    _todayReject = json['TodayReject'];
    _yesterdayReject = json['YesterdayReject'];
    _rejectDifference = json['RejectDifference'];
    _todayTotal = json['TodayTotal'];
    _yesterdayTotal = json['YesterdayTotal'];
    _totalDifference = json['TotalDifference'];
  }
  String? _timeRange;
  num? _lineId;
  num? _buyerId;
  String? _buyerName;
  String? _po;
  String? _style;
  num? _todayPass;
  num? _yesterdayPass;
  num? _passDiffrence;
  num? _todayAlteration;
  num? _yesterdayAlteration;
  num? _alterationDifference;
  num? _todayAlterCheck;
  num? _yesterdayAlterCheck;
  num? _alterCheckDifference;
  num? _todayReject;
  num? _yesterdayReject;
  num? _rejectDifference;
  num? _todayTotal;
  num? _yesterdayTotal;
  num? _totalDifference;
DifferenceCountModel copyWith({  String? timeRange,
  num? lineId,
  num? buyerId,
  String? buyerName,
  String? po,
  String? style,
  num? todayPass,
  num? yesterdayPass,
  num? passDiffrence,
  num? todayAlteration,
  num? yesterdayAlteration,
  num? alterationDifference,
  num? todayAlterCheck,
  num? yesterdayAlterCheck,
  num? alterCheckDifference,
  num? todayReject,
  num? yesterdayReject,
  num? rejectDifference,
  num? todayTotal,
  num? yesterdayTotal,
  num? totalDifference,
}) => DifferenceCountModel(  timeRange: timeRange ?? _timeRange,
  lineId: lineId ?? _lineId,
  buyerId: buyerId ?? _buyerId,
  buyerName: buyerName ?? _buyerName,
  po: po ?? _po,
  style: style ?? _style,
  todayPass: todayPass ?? _todayPass,
  yesterdayPass: yesterdayPass ?? _yesterdayPass,
  passDiffrence: passDiffrence ?? _passDiffrence,
  todayAlteration: todayAlteration ?? _todayAlteration,
  yesterdayAlteration: yesterdayAlteration ?? _yesterdayAlteration,
  alterationDifference: alterationDifference ?? _alterationDifference,
  todayAlterCheck: todayAlterCheck ?? _todayAlterCheck,
  yesterdayAlterCheck: yesterdayAlterCheck ?? _yesterdayAlterCheck,
  alterCheckDifference: alterCheckDifference ?? _alterCheckDifference,
  todayReject: todayReject ?? _todayReject,
  yesterdayReject: yesterdayReject ?? _yesterdayReject,
  rejectDifference: rejectDifference ?? _rejectDifference,
  todayTotal: todayTotal ?? _todayTotal,
  yesterdayTotal: yesterdayTotal ?? _yesterdayTotal,
  totalDifference: totalDifference ?? _totalDifference,
);
  String? get timeRange => _timeRange;
  num? get lineId => _lineId;
  num? get buyerId => _buyerId;
  String? get buyerName => _buyerName;
  String? get po => _po;
  String? get style => _style;
  num? get todayPass => _todayPass;
  num? get yesterdayPass => _yesterdayPass;
  num? get passDiffrence => _passDiffrence;
  num? get todayAlteration => _todayAlteration;
  num? get yesterdayAlteration => _yesterdayAlteration;
  num? get alterationDifference => _alterationDifference;
  num? get todayAlterCheck => _todayAlterCheck;
  num? get yesterdayAlterCheck => _yesterdayAlterCheck;
  num? get alterCheckDifference => _alterCheckDifference;
  num? get todayReject => _todayReject;
  num? get yesterdayReject => _yesterdayReject;
  num? get rejectDifference => _rejectDifference;
  num? get todayTotal => _todayTotal;
  num? get yesterdayTotal => _yesterdayTotal;
  num? get totalDifference => _totalDifference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['TimeRange'] = _timeRange;
    map['LineId'] = _lineId;
    map['BuyerId'] = _buyerId;
    map['BuyerName'] = _buyerName;
    map['PO'] = _po;
    map['Style'] = _style;
    map['TodayPass'] = _todayPass;
    map['YesterdayPass'] = _yesterdayPass;
    map['PassDiffrence'] = _passDiffrence;
    map['TodayAlteration'] = _todayAlteration;
    map['YesterdayAlteration'] = _yesterdayAlteration;
    map['AlterationDifference'] = _alterationDifference;
    map['TodayAlterCheck'] = _todayAlterCheck;
    map['YesterdayAlterCheck'] = _yesterdayAlterCheck;
    map['AlterCheckDifference'] = _alterCheckDifference;
    map['TodayReject'] = _todayReject;
    map['YesterdayReject'] = _yesterdayReject;
    map['RejectDifference'] = _rejectDifference;
    map['TodayTotal'] = _todayTotal;
    map['YesterdayTotal'] = _yesterdayTotal;
    map['TotalDifference'] = _totalDifference;
    return map;
  }

}