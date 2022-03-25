import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/models/client.dart';

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
}
