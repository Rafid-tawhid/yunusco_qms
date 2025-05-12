class ColorModel {
  ColorModel({
      String? colorId,
      String? po,
      String? color,}){
    _colorId = colorId;
    _po = po;
    _color = color;
}

  ColorModel.fromJson(dynamic json) {
    _colorId = json['ColorId'].toString();
    _po = json['PO'].toString();
    _color = json['Color'].toString();
  }
  String? _colorId;
  String? _po;
  String? _color;
ColorModel copyWith({  String? colorId,
  String? po,
  String? color,
}) => ColorModel(  colorId: colorId ?? _colorId,
  po: po ?? _po,
  color: color ?? _color,
);
  String? get colorId => _colorId;
  String? get po => _po;
  String? get color => _color;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ColorId'] = _colorId;
    map['PO'] = _po;
    map['Color'] = _color;
    return map;
  }

}