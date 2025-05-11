import 'package:nidle_qty/models/defect_models.dart';

class FirebaseDataModel {
  FirebaseDataModel({
    String? employeeId,
    String? sectionId,
    String? lineId,
    String? checkTime,
    String? status,
    String? buyer,
    String? style,
    String? po,
    String? color,
    String? size,
    DateTime? timeStamp,
    List<DefectModels>? defects,
  }) {
    _employeeId = employeeId;
    _sectionId = sectionId;
    _lineId = lineId;
    _checkTime = checkTime;
    _status = status;
    _buyer = buyer;
    _style = style;
    _po = po;
    _color = color;
    _size = size;
    _defects = defects;
    _timeStamp=timeStamp;
  }

  FirebaseDataModel.fromJson(dynamic json) {
    _employeeId = json['employee_id'];

    _sectionId = json['section_id'];
    _lineId = json['line_id'];
    _checkTime = json['check_time'];
    _status = json['status'];
    _buyer = json['buyer'];
    _style = json['style'];
    _po = json['po'];
    _color = json['color'];
    _size = json['size'];
    _timeStamp=json['timeStamp'];
    if (json['defects'] != null) {
      _defects = [];
      json['defects'].forEach((v) {
        _defects?.add(DefectModels.fromJson(v));
      });
    }
  }

  String? _employeeId;

  String? _sectionId;
  String? _lineId;
  String? _checkTime;
  String? _status;
  String? _buyer;
  String? _style;
  String? _po;
  String? _color;
  String? _size;
  List<DefectModels>? _defects;
  DateTime? _timeStamp;

  FirebaseDataModel copyWith({
    String? employeeId,
    String? sectionId,
    String? lineId,
    String? checkTime,
    String? status,
    String? buyer,
    String? style,
    String? po,
    String? color,
    String? size,
    List<DefectModels>? defects,
  }) =>
      FirebaseDataModel(
        employeeId: employeeId ?? _employeeId,
        sectionId: sectionId ?? _sectionId,
        lineId: lineId ?? _lineId,
        checkTime: checkTime ?? _checkTime,
        status: status ?? _status,
        buyer: buyer ?? _buyer,
        style: style ?? _style,
        po: po ?? _po,
        color: color ?? _color,
        size: size ?? _size,
        defects: defects ?? _defects,
      );

  String? get employeeId => _employeeId;

  String? get sectionId => _sectionId;
  String? get lineId => _lineId;
  String? get checkTime => _checkTime;
  String? get status => _status;
  String? get buyer => _buyer;
  String? get style => _style;
  String? get po => _po;
  String? get color => _color;
  String? get size => _size;
  List<DefectModels>? get defects => _defects;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employee_id'] = _employeeId;
    map['section_id'] = _sectionId;
    map['line_id'] = _lineId;
    map['check_time'] = _checkTime;
    map['status'] = _status;
    map['buyer'] = _buyer;
    map['style'] = _style;
    map['po'] = _po;
    map['color'] = _color;
    map['size'] = _size;
    if (_defects != null) {
      map['defects'] = _defects?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

