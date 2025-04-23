class DefectModels {
  DefectModels({
      num? defectId, 
      String? defectName, 
      num? operationId,}){
    _defectId = defectId;
    _defectName = defectName;
    _operationId = operationId;
}

  DefectModels.fromJson(dynamic json) {
    _defectId = json['defectId'];
    _defectName = json['defectName'];
    _operationId = json['operationId'];
  }
  num? _defectId;
  String? _defectName;
  num? _operationId;
DefectModels copyWith({  num? defectId,
  String? defectName,
  num? operationId,
}) => DefectModels(  defectId: defectId ?? _defectId,
  defectName: defectName ?? _defectName,
  operationId: operationId ?? _operationId,
);
  num? get defectId => _defectId;
  String? get defectName => _defectName;
  num? get operationId => _operationId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['defectId'] = _defectId;
    map['defectName'] = _defectName;
    map['operationId'] = _operationId;
    return map;
  }

}