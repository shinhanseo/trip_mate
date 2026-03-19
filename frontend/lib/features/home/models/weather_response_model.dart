class LatLon {
  final double lat;
  final double lon;

  LatLon({required this.lat, required this.lon});

  factory LatLon.fromJson(Map<String, dynamic> json) {
    return LatLon(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

class WeatherResponseModel {
  final LatLon coord;
  final String name;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String main;
  final String description;
  final String icon;
  final int dt;

  WeatherResponseModel({
    required this.coord,
    required this.name,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.main,
    required this.description,
    required this.icon,
    required this.dt,
  });

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    return WeatherResponseModel(
      coord: LatLon.fromJson(json['coord']),
      name: json['name'] as String,
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      dt: json['dt'] as int,
    );
  }
}
