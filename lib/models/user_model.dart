class UserModel {
  //

  UserModel({
      String? userRoleName, 
      String? designation, 
      String? iDnum, 
      String? userId,
      String? userName, 
      String? loginName, 
      num? roleId,}){
    _userRoleName = userRoleName;
    _designation = designation;
    _iDnum = iDnum;
    _userId = userId;
    _userName = userName;
    _loginName = loginName;
    _roleId = roleId;
}

  UserModel.fromJson(dynamic json) {
     _userRoleName = json['userRoleName'];
    _designation = json['designation'];
    _iDnum = json['iDnum'].toString();
    _userId = json['userId'].toString();
    _userName = json['userName'];
    _loginName = json['loginName'];
    _roleId = json['roleId'];
  }
  String? _userRoleName;
  String? _designation;
  String? _iDnum;
  String? _userId;
  String? _userName;
  String? _loginName;
  num? _roleId;
UserModel copyWith({  String? userRoleName,
  String? designation,
  String? iDnum,
  String? userId,
  String? userName,
  String? loginName,
  num? roleId,
}) => UserModel(  userRoleName: userRoleName ?? _userRoleName,
  designation: designation ?? _designation,
  iDnum: iDnum ?? _iDnum,
  userId: userId ?? _userId,
  userName: userName ?? _userName,
  loginName: loginName ?? _loginName,
  roleId: roleId ?? _roleId,
);
  String? get userRoleName => _userRoleName;
  String? get designation => _designation;
  String? get iDnum => _iDnum;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get loginName => _loginName;
  num? get roleId => _roleId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userRoleName'] = _userRoleName;
    map['designation'] = _designation;
    map['iDnum'] = _iDnum;
    map['userId'] = _userId;
    map['userName'] = _userName;
    map['loginName'] = _loginName;
    map['roleId'] = _roleId;
    return map;
  }

}