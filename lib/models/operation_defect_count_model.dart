class OperationDefectCountModel {
  OperationDefectCountModel({
      num? lineId, 
      String? operationName, 
      String? defectName, 
      num? defectCount,}){
    _lineId = lineId;
    _operationName = operationName;
    _defectName = defectName;
    _defectCount = defectCount;
}

  OperationDefectCountModel.fromJson(dynamic json) {
    _lineId = json['LineId']??'';
    _operationName = json['OperationName']??'';
    _defectName = json['DefectName']??'';
    _defectCount = json['DefectCount']??'';
  }
  num? _lineId;
  String? _operationName;
  String? _defectName;
  num? _defectCount;
OperationDefectCountModel copyWith({  num? lineId,
  String? operationName,
  String? defectName,
  num? defectCount,
}) => OperationDefectCountModel(  lineId: lineId ?? _lineId,
  operationName: operationName ?? _operationName,
  defectName: defectName ?? _defectName,
  defectCount: defectCount ?? _defectCount,
);
  num? get lineId => _lineId;
  String? get operationName => _operationName;
  String? get defectName => _defectName;
  num? get defectCount => _defectCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LineId'] = _lineId;
    map['OperationName'] = _operationName;
    map['DefectName'] = _defectName;
    map['DefectCount'] = _defectCount;
    return map;
  }

}