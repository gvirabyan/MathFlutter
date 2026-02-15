import 'package:dio/dio.dart';

class GooglePlacesService {
  final String apiKey = "AIzaSyCD7Qcig2DhVVp5nNahOZuJJOjnyvIExks";
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> searchPlaces(String query, String type) async {

    final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&types=$type"
        "&key=$apiKey";

    final response = await _dio.get(url);
    final predictions = response.data['predictions'] as List;

    return predictions.map((p) => {
      'description': p['description'],
      'place_id': p['place_id'],
    }).toList();
  }
}