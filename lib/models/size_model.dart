class SizeModel {
  SizeModel({
      String? sizeId,
      String? po,
      String? size,}){
    _sizeId = sizeId;
    _po = po;
    _size = size;
}

  SizeModel.fromJson(dynamic json) {
    _sizeId = json['SizeId'].toString();
    _po = json['PO'].toString();
    _size = json['Size'].toString();
  }
  String? _sizeId;
  String? _po;
  String? _size;
SizeModel copyWith({  String? sizeId,
  String? po,
  String? size,
}) => SizeModel(  sizeId: sizeId ?? _sizeId,
  po: po ?? _po,
  size: size ?? _size,
);
  String? get sizeId => _sizeId;
  String? get po => _po;
  String? get size => _size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SizeId'] = _sizeId;
    map['PO'] = _po;
    map['Size'] = _size;
    return map;
  }

}