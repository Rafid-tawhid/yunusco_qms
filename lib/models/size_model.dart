class SizeModel {
  SizeModel({
      String? po, 
      String? sIze,}){
    _po = po;
    _sIze = sIze;
}

  SizeModel.fromJson(dynamic json) {
    _po = json['PO'];
    _sIze = json['Size'];
  }
  String? _po;
  String? _sIze;
SizeModel copyWith({  String? po,
  String? sIze,
}) => SizeModel(  po: po ?? _po,
  sIze: sIze ?? _sIze,
);
  String? get po => _po;
  String? get sIze => _sIze;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PO'] = _po;
    map['Size'] = _sIze;
    return map;
  }

}