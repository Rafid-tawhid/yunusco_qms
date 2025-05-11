class DefectModels {
  DefectModels({
      num? defectId, 
      String? defectName,
      String? operationName,
      num? operationId,}){
    _defectId = defectId;
    _defectName = defectName;
    _operationId = operationId;
}

  DefectModels.fromJson(dynamic json) {
    _defectId = json['DefectId'];
    _defectName = json['DefectName'];
    _operationId = json['OperationId'];
    _operationId = json['OperationName'];
  }
  num? _defectId;
  String? _defectName;
  String? _operationtName;
  num? _operationId;
DefectModels copyWith({  num? defectId,
  String? defectName,
  num? operationId,
  String? operationName
}) => DefectModels(  defectId: defectId ?? _defectId,
  defectName: defectName ?? _defectName,
  operationId: operationId ?? _operationId,
  operationName: operationName??_operationtName
);
  num? get defectId => _defectId;
  String? get defectName => _defectName;
  String? get operationName => _operationtName;
  num? get operationId => _operationId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DefectId'] = _defectId;
    map['DefectName'] = _defectName;
    map['OperationId'] = _operationId;
    map['OperationName'] = _operationtName;
    return map;
  }

}