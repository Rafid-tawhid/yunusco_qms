class ColorModel {
  ColorModel({
      String? po, 
      String? color,}){
    _po = po;
    _color = color;
}

  ColorModel.fromJson(dynamic json) {
    _po = json['po'];
    _color = json['color'];
  }
  String? _po;
  String? _color;
ColorModel copyWith({  String? po,
  String? color,
}) => ColorModel(  po: po ?? _po,
  color: color ?? _color,
);
  String? get po => _po;
  String? get color => _color;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['po'] = _po;
    map['color'] = _color;
    return map;
  }

}