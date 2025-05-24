class DefectModels {
  DefectModels({
    num? defectId,
    String? defectName,
    num? status, // Added status field
  }) {
    _defectId = defectId;
    _defectName = defectName;
    _status = status; // Initialize status
  }

  DefectModels.fromJson(dynamic json) {
    _defectId = json['DefectId'];
    _defectName = json['DefectName'];
    _status = json['Status']; // Parse status from JSON
  }

  num? _defectId;
  String? _defectName;
  num? _status; // Private status variable

  DefectModels copyWith({
    num? defectId,
    String? defectName,
    num? status, // Added to copyWith
  }) => DefectModels(
    defectId: defectId ?? _defectId,
    defectName: defectName ?? _defectName,
    status: status ?? _status, // Include status in copy
  );

  num? get defectId => _defectId;
  String? get defectName => _defectName;
  num? get status => _status; // Status getter

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DefectId'] = _defectId;
    map['DefectName'] = _defectName;
    map['Status'] = _status; // Include status in JSON
    return map;
  }
}