import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/utils/debugger.dart';

enum FetchStatus { loading, done, error }
enum ProcessedStatus { next, retry }

class ProcessedResponse {
  ProcessedStatus status;
  dynamic body;
  int? statusCode;
  ProcessedResponse(this.status, {this.statusCode, this.body});
}

class CResponse {
  late dynamic body;
  late int code;

  CResponse(this.body, this.code);
}

class Server {
  static String userBaseUrl = Manager.isDev ? 'renohouzuser-wg4sseexsa-as.a.run.app' : '';
  static String jobBaseUrl = Manager.isDev ? 'renohouzjob-wg4sseexsa-as.a.run.app' : '';

  /// return json decoded body (jsonDecode(response.body))
  static Future<CResponse> httpPost(String baseUrl, String path, Map body, String errorMessage) async {
    http.Response response = await simpleHttpPost(baseUrl, path, body);
    ProcessedResponse? res = await _processResponse(response);
    if (res!.status == ProcessedStatus.next) {
      return CResponse(jsonDecode(res.body), res.statusCode!);
    } else if (res.status == ProcessedStatus.retry) {
      http.Response re = await simpleHttpPost(baseUrl, path, body);
      if (re.statusCode == 200) {
        return CResponse(jsonDecode(re.body), res.statusCode!);
      } else {
        throw Exception(errorMessage);
      }
    } else {
      throw Exception(errorMessage);
    }
  }

  /// return json decoded body (jsonDecode(response.body))
  static Future<CResponse> httpGet(String baseUrl, String path, String errorMessage) async {
    http.Response response = await simpleHttpGet(baseUrl, path);
    ProcessedResponse? res = await _processResponse(response);
    if (res!.status == ProcessedStatus.next) {
      return CResponse(jsonDecode(res.body), res.statusCode!);
    } else if (res.status == ProcessedStatus.retry) {
      http.Response re = await simpleHttpGet(baseUrl, path);
      if (re.statusCode == 200) {
        return CResponse(jsonDecode(re.body), re.statusCode);
      } else {
        throw Exception(errorMessage);
      }
    } else {
      throw Exception(errorMessage);
    }
  }

  /// return json decoded body (jsonDecode(response.body))
  static Future<CResponse> httpPut(String baseUrl, String path, Map body, String errorMessage) async {
    http.Response response = await simpleHttpPut(baseUrl, path, body);
    ProcessedResponse? res = await _processResponse(response);
    if (res!.status == ProcessedStatus.next) {
      return CResponse(jsonDecode(res.body), res.statusCode!);
    } else if (res.status == ProcessedStatus.retry) {
      http.Response re = await simpleHttpPut(baseUrl, path, body);
      if (re.statusCode == 200) {
        return CResponse(jsonDecode(re.body), re.statusCode);
      } else {
        throw Exception(errorMessage);
      }
    } else {
      throw Exception(errorMessage);
    }
  }

  /// return json decoded body (jsonDecode(response.body))
  static Future<CResponse> httpDelete(String baseUrl, String path, Map body, String errorMessage) async {
    http.Response response = await simpleHttpDelete(baseUrl, path, body);
    ProcessedResponse? res = await _processResponse(response);
    if (res!.status == ProcessedStatus.next) {
      return CResponse(jsonDecode(res.body), res.statusCode!);
    } else if (res.status == ProcessedStatus.retry) {
      http.Response re = await simpleHttpDelete(baseUrl, path, body);
      if (re.statusCode == 200) {
        return CResponse(jsonDecode(re.body), re.statusCode);
      } else {
        throw Exception(errorMessage);
      }
    } else {
      throw Exception(errorMessage);
    }
  }

  /// return json decoded body (jsonDecode(response.body))
  static Future<CResponse> httpMultiPart(
      String baseUrl, String path, String fileKey, String filePath, Map body, String errorMessage) async {
    http.StreamedResponse response = await simpleHttpMultiPart(baseUrl, path, fileKey, filePath, body);
    ProcessedResponse? res = await _processStreamedResponse(response);
    if (res!.status == ProcessedStatus.next) {
      return CResponse(jsonDecode(res.body), res.statusCode!);
    } else if (res.status == ProcessedStatus.retry) {
      http.StreamedResponse re = await simpleHttpMultiPart(baseUrl, path, fileKey, filePath, body);
      if (re.statusCode == 200) {
        return CResponse(jsonDecode(re.stream.toString()), re.statusCode);
      } else {
        throw Exception(errorMessage);
      }
    } else {
      throw Exception(errorMessage);
    }
  }

  static Future<http.StreamedResponse> simpleHttpMultiPart(
      String baseUrl, String path, String fileKey, String filePath, Map body) async {
    var request = http.MultipartRequest('PUT', Uri.https(baseUrl, path));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${Manager.jwt}';
    body.forEach((key, value) {
      request.fields[key] = value;
    });
    request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
    final response = await request.send();
    return response;
  }

  static Future<http.Response> simpleHttpPost(String baseUrl, String path, Map body) async {
    Map<String, String> _headers = {'Content-Type': 'application/json; charset=UTF-8'};
    _headers[HttpHeaders.authorizationHeader] = 'Bearer ${Manager.jwt}';
    final Uri uri = Uri.https(baseUrl, path);
    final response = await http.post(uri, headers: _headers, body: jsonEncode(body));
    return response;
  }

  static Future<http.Response> simpleHttpGet(String baseUrl, String path) async {
    Map<String, String> _headers = {'Content-Type': 'application/json; charset=UTF-8'};
    _headers[HttpHeaders.authorizationHeader] = 'Bearer ${Manager.jwt}';
    final Uri uri = Uri.https(baseUrl, path);
    final response = await http.get(uri, headers: _headers);
    return response;
  }

  static Future<http.Response> simpleHttpPut(String baseUrl, String path, Map body) async {
    Map<String, String> _headers = {'Content-Type': 'application/json; charset=UTF-8'};
    _headers[HttpHeaders.authorizationHeader] = 'Bearer ${Manager.jwt}';
    final Uri uri = Uri.https(baseUrl, path);
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body));
    return response;
  }

  static Future<http.Response> simpleHttpDelete(String baseUrl, String path, Map body) async {
    Map<String, String> _headers = {'Content-Type': 'application/json; charset=UTF-8'};
    _headers[HttpHeaders.authorizationHeader] = 'Bearer ${Manager.jwt}';
    final Uri uri = Uri.https(baseUrl, path);
    final response = await http.delete(uri, headers: _headers, body: jsonEncode(body));
    return response;
  }

  //return ok | retry | error
  // ignore: missing_return
  static Future<ProcessedResponse?> _processResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await Manager.signOut();
    } else if (response.statusCode == 403) {
      String idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      final http.Response res = await Server.simpleHttpPost(
        Server.userBaseUrl,
        '/customer/verify',
        {'token': idToken},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        await Manager.saveJwtToken(body['token']);
        return ProcessedResponse(ProcessedStatus.retry);
      } else if (res.statusCode == 400) {
        await Manager.signOut();
        FirebaseAuth.instance.signOut();
      } else {
        throw Exception('Error to refresh token');
      }
    } else {
      return ProcessedResponse(ProcessedStatus.next, statusCode: response.statusCode, body: response.body);
    }
  }

  static Future<ProcessedResponse?> _processStreamedResponse(http.StreamedResponse response) async {
    if (response.statusCode == 401) {
      await Manager.signOut();
    } else if (response.statusCode == 403) {
      String idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      final http.Response res = await Server.simpleHttpPost(
        Server.userBaseUrl,
        '/customer/verify',
        {'token': idToken},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        await Manager.saveJwtToken(body['token']);
        return ProcessedResponse(ProcessedStatus.retry);
      } else if (res.statusCode == 400) {
        await Manager.signOut();
        FirebaseAuth.instance.signOut();
      } else {
        throw Exception('Error to refresh token');
      }
    } else {
      return ProcessedResponse(ProcessedStatus.next, statusCode: response.statusCode, body: await response.stream.bytesToString());
    }
  }
}
