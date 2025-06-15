import 'package:flutter/cupertino.dart';

import '../models/ErrorResponse.dart';
import '../services/AccountService.dart';

class RegisterviewModel extends ChangeNotifier {
  final AccountService _accountService = AccountService();
  bool _isRegistered = false;
  String errorMessage = '';

  Future<bool> register(String email, String password) async {
    try {
      _isRegistered = await _accountService.register(email, password);
      return _isRegistered;
    } catch (e) {
      if (e is BadRequestException) {
        errorMessage = e.message;
      } else if (e is ServerException) {
        errorMessage = 'Błąd serwera: ${e.message}';
      } else if (e is FetchDataException) {
        errorMessage = 'Problem z połączeniem: ${e.message}';
      } else {
        errorMessage = 'Nieznany błąd. Spróbuj ponownie później.';
      }
      notifyListeners();
      return false;
    }
  }
}
