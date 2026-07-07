import 'package:shared_preferences/shared_preferences.dart';

// Kullanicinin secebilecegi uygulama ayarlarini kalici tutar (su an icin
// sadece ozel dosya kayit konumu - Windows'a ozel, iOS sabit kalir).
class SettingsService {
  static const _saveDirectoryKey = 'save_directory';

  Future<String?> getSaveDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_saveDirectoryKey);
  }

  Future<void> setSaveDirectory(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_saveDirectoryKey);
    } else {
      await prefs.setString(_saveDirectoryKey, path);
    }
  }
}
