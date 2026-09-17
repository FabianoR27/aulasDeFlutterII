class WeatherModel {
  final String city;
  final String region;
  final String country;
  final double temperature;
  final String condition;
  final String iconUrl;
  final double windSpeed;
  final int humidity;
  final double feelsLike;

  WeatherModel({
    required this.city,
    required this.region,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['location']['name'] ?? 'N/A',
      region: json['location']['region'] ?? 'N/A',
      country: json['location']['country'] ?? 'N/A',
      temperature: (json['current']['temp_c'] ?? 0).toDouble(),
      condition: json['current']['condition']['text'] ?? 'N/A',
      iconUrl: 'https:${json['current']['condition']['icon'] ?? ''}',
      windSpeed: (json['current']['wind_kph'] ?? 0).toDouble(),
      humidity: json['current']['humidity'] ?? 0,
      feelsLike: (json['current']['feelslike_c'] ?? 0).toDouble(),
    );
  }
}
