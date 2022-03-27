import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/utils/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppStatus { loading, serverMaintenance, toRegister, toUploadPhoto, toVerifyPhoneNumber, completed }

class Manager {
  static bool _isLoadingOnStart = false;
  static ValueNotifier<AppStatus> status = ValueNotifier(AppStatus.loading);
  static late String latestAppVersion;
  static const bool isDev = true;
  static String language = 'en';
  static String? jwt;

  static void restartApp() {
    _isLoadingOnStart = false;
  }

  static Future<void> processOnStart(data, UserProvider user) async {
    if (!(data['registered'])) {
      Manager.status.value = AppStatus.toRegister;
      return;
    }
    user.loadDetails(data['workerDetails']);
    if (data['workerDetails']['photoUrl'] == null) {
      Manager.status.value = AppStatus.toUploadPhoto;
      return;
    }
    //Debugger.log("TODO: IOS");
    //latestAppVersion = data['androidVersion'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneVerified = prefs.getBool('phoneVerified') ?? false;
    if (data['phoneVerified'] && phoneVerified) {
      Manager.status.value = AppStatus.completed;
    } else {
      Manager.status.value = AppStatus.toVerifyPhoneNumber;
    }
  }

  static Future onStart(UserProvider user) async {
    // prevent from calling twice
    try {
      if (!_isLoadingOnStart) {
        _isLoadingOnStart = true;
        Manager.status.value = AppStatus.loading;
        await loadJwtToken();
        final res = await Server.httpGet(Server.userBaseUrl, '/worker/get', 'Error to fetch data on start');
        if (res.code == 200) {
          processOnStart(res.body, user);
        } else if (res.code == 503 && res.body['code'] == 'maintenance') {
          Manager.status.value = AppStatus.serverMaintenance;
          return;
        } else {
          throw Exception('Error to fetch data on start');
        }
      }
    } catch (e) {
      Debugger.log(e);
      _isLoadingOnStart = false;
      throw Exception(e);
    }
  }

  static Future saveJwtToken(String token) async {
    jwt = token;
    const storage = FlutterSecureStorage();
    await storage.write(key: 'jwt', value: token);
  }

  static Future loadJwtToken() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    jwt = await storage.read(key: 'jwt');
    if (jwt == null) {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await Server.simpleHttpPost(Server.userBaseUrl, '/worker/login', {'token': idToken});
      if (res.statusCode == 200) {
        final tkn = jsonDecode(res.body)['token'];
        await saveJwtToken(tkn);
      } else if (res.statusCode == 400) {
        signOut();
      } else {
        throw Exception('Error to verify id');
      }
    }
  }

  static Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneVerified');
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt');
    jwt = null;
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
