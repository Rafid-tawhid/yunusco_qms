class TotalCountingModel {
  TotalCountingModel({
    num? totalPass,
    num? totalAlter,
    num? totalAlterCheck,
    num? totalReject,
  }) {
    _totalPass = totalPass;
    _totalAlter = totalAlter;
    _totalAlterCheck = totalAlterCheck;
    _totalReject = totalReject;
  }

  TotalCountingModel.fromJson(dynamic json) {
    _totalPass = json['TotalPass'];
    _totalAlter = json['TotalAlter'];
    _totalAlterCheck = json['TotalAlterCheck'];
    _totalReject = json['TotalReject'];
  }
  num? _totalPass;
  num? _totalAlter;
  num? _totalAlterCheck;
  num? _totalReject;
  TotalCountingModel copyWith({
    num? totalPass,
    num? totalAlter,
    num? totalAlterCheck,
    num? totalReject,
  }) => TotalCountingModel(
    totalPass: totalPass ?? _totalPass,
    totalAlter: totalAlter ?? _totalAlter,
    totalAlterCheck: totalAlterCheck ?? _totalAlterCheck,
    totalReject: totalReject ?? _totalReject,
  );
  num? get totalPass => _totalPass;
  num? get totalAlter => _totalAlter;
  num? get totalAlterCheck => _totalAlterCheck;
  num? get totalReject => _totalReject;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['TotalPass'] = _totalPass;
    map['TotalAlter'] = _totalAlter;
    map['TotalAlterCheck'] = _totalAlterCheck;
    map['TotalReject'] = _totalReject;
    return map;
  }
}
