class SizeModel {
  SizeModel({
      String? po, 
      String? sIze,}){
    _po = po;
    _sIze = sIze;
}

  SizeModel.fromJson(dynamic json) {
    _po = json['po'];
    _sIze = json['sIze'];
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
    map['po'] = _po;
    map['sIze'] = _sIze;
    return map;
  }

}