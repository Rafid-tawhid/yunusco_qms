class PoModels {
  PoModels({
      String? style, 
      String? po, 
      String? itemId,}){
    _style = style;
    _po = po;
    _itemId = itemId;
}

  PoModels.fromJson(dynamic json) {
    _style = json['Style'];
    _po = json['PO'];
    _itemId = json['ItemId'];
  }
  String? _style;
  String? _po;
  String? _itemId;
PoModels copyWith({  String? style,
  String? po,
  String? itemId,
}) => PoModels(  style: style ?? _style,
  po: po ?? _po,
  itemId: itemId ?? _itemId,
);
  String? get style => _style;
  String? get po => _po;
  String? get itemId => _itemId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Style'] = _style;
    map['PO'] = _po;
    map['ItemId'] = _itemId;
    return map;
  }

}