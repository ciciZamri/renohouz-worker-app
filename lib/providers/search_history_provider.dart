import 'package:flutter/foundation.dart';

class SearchHistoryProvider extends ChangeNotifier {
  List<String>? list;

  void fetch() async {
    list = await Future.delayed(Duration(seconds: 2), () => ['potong rumput', 'pasang kipas', 'pasang suis']);
    notifyListeners();
  }

  void add(String word){}
}
