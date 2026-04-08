import 'dart:io';

class PhotoMetadata {
  final int? id;
  final String filePath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String address;
  final String city;
  final String? filterName;

  PhotoMetadata({
    this.id,
    required this.filePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.address,
    required this.city,
    this.filterName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'city': city,
      'filter_name': filterName,
    };
  }

  factory PhotoMetadata.fromMap(Map<String, dynamic> map) {
    return PhotoMetadata(
      id: map['id'],
      filePath: map['file_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      address: map['address'],
      city: map['city'],
      filterName: map['filter_name'],
    );
  }

  File get file => File(filePath);
}
