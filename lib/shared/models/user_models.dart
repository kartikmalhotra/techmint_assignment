class AppUser {
  static bool? isLoggedIn = false;
  static String userId = '';
  static String email = '';
  static String password = '';
  static String authToken = '';
  static String name = '';
  static String photoUrl = "";

  AppUser.map(dynamic obj) {
    userId = obj["user_id"];
    email = obj["email"];
    password = obj["password"];
    authToken = obj["auth_token"];
    name = obj["name"];
    isLoggedIn = true;
  }

  static Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["email"] = email;
    map["password"] = password;
    map["authToken"] = authToken;
    map["name"] = name;
    return map;
  }

  static setUserParams(Map<dynamic, dynamic>? oauthResp) {
    if (oauthResp != null) {
      userId = oauthResp['data']?['userId']?.toString() ?? "";
      email = oauthResp['data']?['email'] ?? "";
      password = '';
      name = oauthResp["data"]?["name"] ?? "";
      authToken = oauthResp['data']?['token'] ?? "";
      isLoggedIn = true;
    }
  }

  static deleteUser() {
    userId = '';
    email = '';
    password = '';
    authToken = '';
    isLoggedIn = false;
  }

  static saveUserParamsFromDatabase(Map<String, dynamic> map) {
    userId = map["userId"];
    email = map["email"];
    password = map["password"];
    authToken = map["authToken"];
    name = map["name"];
    isLoggedIn = true;
  }
}
