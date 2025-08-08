import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GetLocation {
  static Future<Position> getCurrentCordinartes() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      debugPrint("Ask User To Switch On Location");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location Permission Denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("User Need to Give permistion from app settings");
    }

    return await Geolocator.getCurrentPosition();
  }
}
