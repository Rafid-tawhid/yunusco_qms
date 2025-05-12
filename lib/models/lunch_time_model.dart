class LunchTimeModel {
  LunchTimeModel({
      String? lunchStartTime, 
      String? lunchEndTime, 
      num? sectionId, 
      num? lunchTimeId,}){
    _lunchStartTime = lunchStartTime;
    _lunchEndTime = lunchEndTime;
    _sectionId = sectionId;
    _lunchTimeId = lunchTimeId;
}

  LunchTimeModel.fromJson(dynamic json) {
    _lunchStartTime = json['LunchStartTime'];
    _lunchEndTime = json['LunchEndTime'];
    _sectionId = json['SectionId'];
    _lunchTimeId = json['LunchTimeId'];
  }
  String? _lunchStartTime;
  String? _lunchEndTime;
  num? _sectionId;
  num? _lunchTimeId;
LunchTimeModel copyWith({  String? lunchStartTime,
  String? lunchEndTime,
  num? sectionId,
  num? lunchTimeId,
}) => LunchTimeModel(  lunchStartTime: lunchStartTime ?? _lunchStartTime,
  lunchEndTime: lunchEndTime ?? _lunchEndTime,
  sectionId: sectionId ?? _sectionId,
  lunchTimeId: lunchTimeId ?? _lunchTimeId,
);
  String? get lunchStartTime => _lunchStartTime;
  String? get lunchEndTime => _lunchEndTime;
  num? get sectionId => _sectionId;
  num? get lunchTimeId => _lunchTimeId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LunchStartTime'] = _lunchStartTime;
    map['LunchEndTime'] = _lunchEndTime;
    map['SectionId'] = _sectionId;
    map['LunchTimeId'] = _lunchTimeId;
    return map;
  }

}