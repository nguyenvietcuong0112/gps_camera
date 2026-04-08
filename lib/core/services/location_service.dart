import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String city;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
  });
}

class LocationService {
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return await getLocationDataFromPosition(position);
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  Future<LocationData> getLocationDataFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "Unknown Address";
      String city = "Unknown City";

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address = "${place.street}, ${place.subLocality}, ${place.locality}";
        city = place.locality ?? "Unknown City";
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
      );
    } catch (e) {
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: "Error geocoding",
        city: "Error",
      );
    }
  }

  Stream<LocationData> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).asyncMap((position) => getLocationDataFromPosition(position));
  }
}
