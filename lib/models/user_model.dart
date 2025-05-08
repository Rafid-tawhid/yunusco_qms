class UserModel {
  UserModel({
    String? userRoleName,
    dynamic tokenInfo,
    String? designation,
    String? iDnum,
    num? userId,
    String? userName,
    String? loginName,
    dynamic password,
    num? roleId,
    dynamic isActive,
    dynamic passwordChanged,
    dynamic customerCode,
    dynamic userEmail,
    dynamic lastLogin,
    dynamic rboid,
    dynamic businessUnitId,
    dynamic employeeId,
    dynamic teamId,
    dynamic creator,
    dynamic createDate,
    dynamic modifier,
    dynamic modifiedDate,
    dynamic hasAuthority,
    dynamic firebaseDeviceToken,}){
    _userRoleName = userRoleName;
    _tokenInfo = tokenInfo;
    _designation = designation;
    _iDnum = iDnum;
    _userId = userId;
    _userName = userName;
    _loginName = loginName;
    _password = password;
    _roleId = roleId;
    _isActive = isActive;
    _passwordChanged = passwordChanged;
    _customerCode = customerCode;
    _userEmail = userEmail;
    _lastLogin = lastLogin;
    _rboid = rboid;
    _businessUnitId = businessUnitId;
    _employeeId = employeeId;
    _teamId = teamId;
    _creator = creator;
    _createDate = createDate;
    _modifier = modifier;
    _modifiedDate = modifiedDate;
    _hasAuthority = hasAuthority;
    _firebaseDeviceToken = firebaseDeviceToken;
  }

  UserModel.fromJson(dynamic json) {
    _userRoleName = json['UserRoleName'];
    _tokenInfo = json['TokenInfo'];
    _designation = json['Designation'];
    _iDnum = json['IDnum'];
    _userId = json['UserId'];
    _userName = json['UserName'];
    _loginName = json['LoginName'];
    _password = json['Password'];
    _roleId = json['RoleId'];
    _isActive = json['IsActive'];
    _passwordChanged = json['PasswordChanged'];
    _customerCode = json['CustomerCode'];
    _userEmail = json['UserEmail'];
    _lastLogin = json['LastLogin'];
    _rboid = json['Rboid'];
    _businessUnitId = json['BusinessUnitId'];
    _employeeId = json['EmployeeId'];
    _teamId = json['TeamId'];
    _creator = json['Creator'];
    _createDate = json['CreateDate'];
    _modifier = json['Modifier'];
    _modifiedDate = json['ModifiedDate'];
    _hasAuthority = json['HasAuthority'];
    _firebaseDeviceToken = json['FirebaseDeviceToken'];
  }
  String? _userRoleName;
  dynamic _tokenInfo;
  String? _designation;
  String? _iDnum;
  num? _userId;
  String? _userName;
  String? _loginName;
  dynamic _password;
  num? _roleId;
  dynamic _isActive;
  dynamic _passwordChanged;
  dynamic _customerCode;
  dynamic _userEmail;
  dynamic _lastLogin;
  dynamic _rboid;
  dynamic _businessUnitId;
  dynamic _employeeId;
  dynamic _teamId;
  dynamic _creator;
  dynamic _createDate;
  dynamic _modifier;
  dynamic _modifiedDate;
  dynamic _hasAuthority;
  dynamic _firebaseDeviceToken;
  UserModel copyWith({  String? userRoleName,
    dynamic tokenInfo,
    String? designation,
    String? iDnum,
    num? userId,
    String? userName,
    String? loginName,
    dynamic password,
    num? roleId,
    dynamic isActive,
    dynamic passwordChanged,
    dynamic customerCode,
    dynamic userEmail,
    dynamic lastLogin,
    dynamic rboid,
    dynamic businessUnitId,
    dynamic employeeId,
    dynamic teamId,
    dynamic creator,
    dynamic createDate,
    dynamic modifier,
    dynamic modifiedDate,
    dynamic hasAuthority,
    dynamic firebaseDeviceToken,
  }) => UserModel(  userRoleName: userRoleName ?? _userRoleName,
    tokenInfo: tokenInfo ?? _tokenInfo,
    designation: designation ?? _designation,
    iDnum: iDnum ?? _iDnum,
    userId: userId ?? _userId,
    userName: userName ?? _userName,
    loginName: loginName ?? _loginName,
    password: password ?? _password,
    roleId: roleId ?? _roleId,
    isActive: isActive ?? _isActive,
    passwordChanged: passwordChanged ?? _passwordChanged,
    customerCode: customerCode ?? _customerCode,
    userEmail: userEmail ?? _userEmail,
    lastLogin: lastLogin ?? _lastLogin,
    rboid: rboid ?? _rboid,
    businessUnitId: businessUnitId ?? _businessUnitId,
    employeeId: employeeId ?? _employeeId,
    teamId: teamId ?? _teamId,
    creator: creator ?? _creator,
    createDate: createDate ?? _createDate,
    modifier: modifier ?? _modifier,
    modifiedDate: modifiedDate ?? _modifiedDate,
    hasAuthority: hasAuthority ?? _hasAuthority,
    firebaseDeviceToken: firebaseDeviceToken ?? _firebaseDeviceToken,
  );
  String? get userRoleName => _userRoleName;
  dynamic get tokenInfo => _tokenInfo;
  String? get designation => _designation;
  String? get iDnum => _iDnum;
  num? get userId => _userId;
  String? get userName => _userName;
  String? get loginName => _loginName;
  dynamic get password => _password;
  num? get roleId => _roleId;
  dynamic get isActive => _isActive;
  dynamic get passwordChanged => _passwordChanged;
  dynamic get customerCode => _customerCode;
  dynamic get userEmail => _userEmail;
  dynamic get lastLogin => _lastLogin;
  dynamic get rboid => _rboid;
  dynamic get businessUnitId => _businessUnitId;
  dynamic get employeeId => _employeeId;
  dynamic get teamId => _teamId;
  dynamic get creator => _creator;
  dynamic get createDate => _createDate;
  dynamic get modifier => _modifier;
  dynamic get modifiedDate => _modifiedDate;
  dynamic get hasAuthority => _hasAuthority;
  dynamic get firebaseDeviceToken => _firebaseDeviceToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserRoleName'] = _userRoleName;
    map['TokenInfo'] = _tokenInfo;
    map['Designation'] = _designation;
    map['IDnum'] = _iDnum;
    map['UserId'] = _userId;
    map['UserName'] = _userName;
    map['LoginName'] = _loginName;
    map['Password'] = _password;
    map['RoleId'] = _roleId;
    map['IsActive'] = _isActive;
    map['PasswordChanged'] = _passwordChanged;
    map['CustomerCode'] = _customerCode;
    map['UserEmail'] = _userEmail;
    map['LastLogin'] = _lastLogin;
    map['Rboid'] = _rboid;
    map['BusinessUnitId'] = _businessUnitId;
    map['EmployeeId'] = _employeeId;
    map['TeamId'] = _teamId;
    map['Creator'] = _creator;
    map['CreateDate'] = _createDate;
    map['Modifier'] = _modifier;
    map['ModifiedDate'] = _modifiedDate;
    map['HasAuthority'] = _hasAuthority;
    map['FirebaseDeviceToken'] = _firebaseDeviceToken;
    return map;
  }

}

//
