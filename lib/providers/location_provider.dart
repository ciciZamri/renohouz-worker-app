import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:renohouz_worker/utils/debugger.dart';

class LocationProvider extends ChangeNotifier {
  late Location _location;
  LocationData? data;
  StreamSubscription? locationStream;
  double minAccuracy = 100.0;

  Location get instance => _location;

  initialize() {
    _location = Location();
  }

  Future<bool> enableLocationService() async {
    bool enabled = await _location.serviceEnabled();
    if (!enabled) {
      enabled = await _location.requestService();
    }
    return enabled;
  }

  Future<bool> enableLocationPermission() async {
    bool granted = false;
    PermissionStatus status = await _location.hasPermission();
    if (status == PermissionStatus.denied) {
      status = await _location.requestPermission();
      if (status == PermissionStatus.granted) {
        granted = true;
      } else {
        granted = false;
      }
    } else {
      granted = true;
    }
    return granted;
  }

  void streamLocation() {
    _location.changeSettings(accuracy: LocationAccuracy.high);
    locationStream = _location.onLocationChanged.listen((LocationData l) async {
      Debugger.log('location stream : ${l.accuracy} ${l.latitude} ${l.longitude}');
      if (l.accuracy! < minAccuracy) {
        locationStream?.cancel();
        data = l;
        notifyListeners();
      }
    });
  }
}
