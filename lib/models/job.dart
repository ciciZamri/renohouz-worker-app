import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/models/client.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/utils/server.dart';

class Job {
  late String id;
  late String title;
  Client? client;
  String? description;
  double? budget;
  double? wage;
  List<double>? location;
  Address? address;
  List<String>? images;
  int? currentOfferCount;
  DateTime? createdAt;
  DateTime? closedAt;
  DateTime? taskCompletedAt;
  DateTime? cancelledAt;
  String? paymentMethod;
  DateTime? paidAt;

  Job.fromMap(Map details) {
    id = details['_id'];
    title = details['title'];
    description = details['description'];
    budget = details['budget']?.toDouble();
    wage = details['wage']?.toDouble();
  }

  static Future<List<String>> queryAutoComplete(String prefix) async {
    return await Future.delayed(Duration(seconds: 1), () => ['test 1', 'test 2', 'test 3']);
  }

  static Future find(String keyword, double lat, double long, int skip, DateTime? firstJobCreatedTime) async {
    String word = 'all';
    if (keyword.isNotEmpty) {
      word = keyword.toLowerCase().replaceAll(RegExp(' +'), '+');
    }
    if (keyword == "Search for jobs") word = 'all';
    int time = firstJobCreatedTime?.millisecondsSinceEpoch ?? 0;
    Debugger.log('/job/find/$word/$lat/$long/5000/$time/$skip/12');
    final result = await Server.httpGet(
      Server.jobBaseUrl,
      '/job/find/$word/$lat/$long/5000/$time/$skip/12',
      'Error to find jobs',
    );
    if (result.code == 200) {
      if (skip == 0) {
        return {
          'count': result.body['count'],
          'jobs': (result.body['jobs'] as List).map((e) => Job.fromMap(e)).toList(),
        };
      } else {
        return (result.body as List).map((e) => Job.fromMap(e)).toList();
      }
    } else {
      throw Exception('Error to find jobs || status: ${result.code}');
    }
  }
}
