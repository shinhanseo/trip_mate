class PlaceSearchModel {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String source;
  final String? regionPrimary;
  final String? regionSecondary;

  PlaceSearchModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.source,
    required this.regionPrimary,
    required this.regionSecondary,
  });

  factory PlaceSearchModel.fromJson(Map<String, dynamic> json) {
    return PlaceSearchModel(
      name: json['name'] as String,
      address: json['address'] as String,
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      source: json['source'] as String,
      regionPrimary: json['regionPrimary'] as String?,
      regionSecondary: json['regionSecondary'] as String?,
    );
  }
}
