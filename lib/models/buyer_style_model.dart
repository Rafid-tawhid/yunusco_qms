class BuyerStyleModel {
  BuyerStyleModel({
      num? buyerId, 
      String? style,String? costingCode}){
    _buyerId = buyerId;
    _style = style;
    _costingCode=costingCode;
}

  BuyerStyleModel.fromJson(dynamic json) {
    _buyerId = json['BuyerId'];
    _style = json['Style'];
    _costingCode = json['CostingCode'];
  }
  num? _buyerId;
  String? _style;
  String? _costingCode;
BuyerStyleModel copyWith({  num? buyerId,
  String? style,
  String? costingCode,
}) => BuyerStyleModel(buyerId: buyerId ?? _buyerId,
  style: style ?? _style,costingCode: costingCode??_costingCode
);
  num? get buyerId => _buyerId;
  String? get style => _style;
  String? get costingCode => _costingCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BuyerId'] = _buyerId;
    map['Style'] = _style;
    map['CostingCode'] = _costingCode;
    return map;
  }

}