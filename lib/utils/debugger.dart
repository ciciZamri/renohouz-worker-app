import 'package:renohouz_worker/manager.dart';

class Debugger {
  static void log(dynamic msg) {
    if (Manager.isDev) {
      print("############################################");
      print(msg);
      print("############################################");
    }
  }
}
