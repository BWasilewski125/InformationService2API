import 'dart:convert';
import 'dart:io';
import '../constants/Constants.dart';
import '../models/ErrorResponse.dart';

class AccountService {
  final String baseUrl = Constants.baseUrl;

  final httpClient = HttpClient();
  static String? token;

  Future<bool> register(String email, String password) async {
    try {
      final uri = Uri.parse("$baseUrl/api/auth/register");
      final request = await httpClient.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");

      request.add(utf8.encode(jsonEncode({
        'email': email,
        'password': password,
      })));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      switch (response.statusCode) {
        case 200:
          return true;
        case 400:
          final errorResponse =
          ErrorResponse.fromJson(jsonDecode(responseBody));
          throw BadRequestException(errorResponse.message);
        case 500:
          final errorResponse =
          ErrorResponse.fromJson(jsonDecode(responseBody));
          throw ServerException(errorResponse.message);
        default:
          throw ServerException('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('Błąd sieci: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final uri = Uri.parse("$baseUrl/api/auth/login");
      final request = await httpClient.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");

      request.add(utf8.encode(jsonEncode({
        'email': email,
        'password': password,
      })));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> json = jsonDecode(responseBody);
          token = json['token'];
          break;

        case 400:
          throw BadRequestException("Nieprawidłowe dane logowania.");

        case 500:
          final errorResponse = ErrorResponse.fromJson(jsonDecode(responseBody));
          throw ServerException(errorResponse.message);

        default:
          throw ServerException('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw FetchDataException('Błąd sieci: ${e.message}');
      } else {
        rethrow;
      }
    }
  }
}
class FetchDataException implements Exception {
  final String message;

  FetchDataException(this.message);
}
