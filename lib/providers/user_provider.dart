import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/utils/server.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String name = 'C';
  String gender = 'male';
  String? photoUrl;
  String? about;
  List<String> skills = [];
  bool? acceptInvitation;
  int? completedJobCount;
  double? rating;
  String? status;
  Address? address;
  DateTime? birthDate;

  String? get phoneNumber => FirebaseAuth.instance.currentUser?.phoneNumber;
  String? get email => FirebaseAuth.instance.currentUser?.email;

  void loadDetails(details) {
    name = details['name'];
    gender = details['gender'];
    address = Address.fromMap({
      ...details['address'],
      'lat': details['location']['coordinates'][1],
      'long': details['location']['coordinates'][1],
    });
    photoUrl = details['photoUrl'];
    gender = details['gender'];
    about = details['about'];
    skills = details['skills'];
    acceptInvitation = details['acceptInvitation'];
    completedJobCount = details['completedJobCount'];
    rating = details['rating'];
    status = details['status'];
  }

  Future<void> register(
      String name, String gender, String about, DateTime birthDate, Address address, List<String> skills) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    await currentUser?.updateDisplayName(name);
    final idToken = await currentUser?.getIdToken();
    final Uri uri = Uri.https(Server.userBaseUrl, '/worker/register');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "token": idToken,
        "name": name,
        "email": currentUser?.email,
        'gender': gender,
        "about": about,
        "birthDate":
            '${birthDate.day.toString().padLeft(2, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.year}',
        "address": address.toMap,
        "lat": address.lat,
        "long": address.long,
        "skills": skills,
      }),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await Manager.saveJwtToken(body['token']);
      Manager.status.value = AppStatus.toUploadPhoto;
    } else if (response.statusCode == 400) {
      throw Exception('Failed to verify id token');
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<void> uploadPhoto(String filePath) async {
    final result = await Server.httpMultiPart(
      Server.userBaseUrl,
      '/worker/photo',
      'image',
      filePath,
      {},
      'Error to upload photo',
    );
    if (result.code == 200) {
      Manager.status.value = AppStatus.pending;
    } else {
      throw Exception('Error to upload photo');
    }
  }

  Future<void> saveFcmToken() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final fcmTokenSaved = pref.getBool('fcmTokenSaved') ?? false;
      if (!fcmTokenSaved) {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        await Server.httpPut(
          Server.userBaseUrl,
          '/worker/fcmtoken',
          {'fcmToken': fcmToken},
          'Failed to save fcm token',
        );
        await pref.setBool('fcmTokenSaved', true);
      }
    } catch (err) {
      Debugger.log(err);
    }
  }

  Future<bool> updateProfile(String about, Address address, List<String> skills) async {
    final result = await Server.httpPut(
      Server.userBaseUrl,
      '/worker/edit',
      {
        "about": about,
        "address": address.toMap,
        "lat": address.lat,
        "long": address.long,
        "skills": skills,
      },
      'Error to update profile',
    );
    if (result.code == 200) {
      this.about = about;
      this.address = address;
      this.skills = skills;
      return true;
    }
    throw Exception('Error to update profile');
  }

  Future updatePhoneNumber(bool firstTime) async {
    await Server.httpPut(
      Server.userBaseUrl,
      '/worker/phone-no',
      {'phoneNo': FirebaseAuth.instance.currentUser?.phoneNumber},
      'Error to update phone number.',
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('phoneVerified', true);
    if (firstTime) {
      Manager.status.value = AppStatus.completed;
    }
  }
}
