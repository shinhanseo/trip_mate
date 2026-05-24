import 'package:shared_preferences/shared_preferences.dart';

class TermsStorage {
  static const String _acceptedKey = 'terms_accepted';
  static const String _acceptedAtKey = 'terms_accepted_at';
  static const String currentVersion = '2026-05-24';

  Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_acceptedKey) == currentVersion;
  }

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_acceptedKey, currentVersion);
    await prefs.setString(_acceptedAtKey, DateTime.now().toIso8601String());
  }
}
