class DefectModels {
  DefectModels({
      num? defectId, 
      String? defectName,}){
    _defectId = defectId;
    _defectName = defectName;
}

  DefectModels.fromJson(dynamic json) {
    _defectId = json['DefectId'];
    _defectName = json['DefectName'];
  }
  num? _defectId;
  String? _defectName;
DefectModels copyWith({  num? defectId,
  String? defectName,
}) => DefectModels(  defectId: defectId ?? _defectId,
  defectName: defectName ?? _defectName,
);
  num? get defectId => _defectId;
  String? get defectName => _defectName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DefectId'] = _defectId;
    map['DefectName'] = _defectName;
    return map;
  }

}