class LunchTimeModel {
  LunchTimeModel({
      String? lunchStartTime, 
      String? lunchEndTime, 
      num? sectionId, 
      num? lunchTimeId, 
      bool? isActive,}){
    _lunchStartTime = lunchStartTime;
    _lunchEndTime = lunchEndTime;
    _sectionId = sectionId;
    _lunchTimeId = lunchTimeId;
    _isActive = isActive;
}

  LunchTimeModel.fromJson(dynamic json) {
    _lunchStartTime = json['LunchStartTime'];
    _lunchEndTime = json['LunchEndTime'];
    _sectionId = json['SectionId'];
    _lunchTimeId = json['LunchTimeId'];
    _isActive = json['IsActive'];
  }
  String? _lunchStartTime;
  String? _lunchEndTime;
  num? _sectionId;
  num? _lunchTimeId;
  bool? _isActive;
LunchTimeModel copyWith({  String? lunchStartTime,
  String? lunchEndTime,
  num? sectionId,
  num? lunchTimeId,
  bool? isActive,
}) => LunchTimeModel(  lunchStartTime: lunchStartTime ?? _lunchStartTime,
  lunchEndTime: lunchEndTime ?? _lunchEndTime,
  sectionId: sectionId ?? _sectionId,
  lunchTimeId: lunchTimeId ?? _lunchTimeId,
  isActive: isActive ?? _isActive,
);
  String? get lunchStartTime => _lunchStartTime;
  String? get lunchEndTime => _lunchEndTime;
  num? get sectionId => _sectionId;
  num? get lunchTimeId => _lunchTimeId;
  bool? get isActive => _isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LunchStartTime'] = _lunchStartTime;
    map['LunchEndTime'] = _lunchEndTime;
    map['SectionId'] = _sectionId;
    map['LunchTimeId'] = _lunchTimeId;
    map['IsActive'] = _isActive;
    return map;
  }

}