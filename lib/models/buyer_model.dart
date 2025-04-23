class BuyerModel {
  BuyerModel({
      String? name, 
      String? code,}){
    _name = name;
    _code = code;
}

  BuyerModel.fromJson(dynamic json) {
    _name = json['name'];
    _code = json['code'].toString();
  }
  String? _name;
  String? _code;
BuyerModel copyWith({  String? name,
  String? code,
}) => BuyerModel(  name: name ?? _name,
  code: code ?? _code,
);
  String? get name => _name;
  String? get code => _code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['code'] = _code;
    return map;
  }

}