import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aplicacao01/models/weather_model.dart';

class WeatherService {
  static const String apiKey = 'fe71d2481a264a9fb0501731261308';
  static const String baseUrl = 'http://api.weatherapi.com/v1/current.json';

  static Future<WeatherModel> getWeather(String city) async {
    try {
      final Uri url = Uri.parse(
        '$baseUrl?key=$apiKey&q=$city&aqi=no',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Falha ao buscar dados do clima');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }
}
