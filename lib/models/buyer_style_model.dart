class BuyerStyleModel {
  BuyerStyleModel({
      num? buyerId, 
      String? style,}){
    _buyerId = buyerId;
    _style = style;
}

  BuyerStyleModel.fromJson(dynamic json) {
    _buyerId = json['buyerId'];
    _style = json['style'];
  }
  num? _buyerId;
  String? _style;
BuyerStyleModel copyWith({  num? buyerId,
  String? style,
}) => BuyerStyleModel(  buyerId: buyerId ?? _buyerId,
  style: style ?? _style,
);
  num? get buyerId => _buyerId;
  String? get style => _style;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['buyerId'] = _buyerId;
    map['style'] = _style;
    return map;
  }

}