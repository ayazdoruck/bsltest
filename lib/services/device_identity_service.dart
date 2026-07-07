import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Cihaza kalıcı bir kimlik (id) ve görünen isim atar; uygulama yeniden
// başlatılsa da aynı kalır, böylece bir cihaz kendi UDP yayınını "yabancı
// peer" olarak görmez (self-filter).
class DeviceIdentityService {
  static const _idKey = 'device_id';
  static const _nameKey = 'device_name';

  String? _id;
  String? _name;

  String get id => _id!;
  String get name => _name!;
  String get platform => Platform.isWindows ? 'windows' : 'ios';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _id = prefs.getString(_idKey);
    if (_id == null) {
      _id = const Uuid().v4();
      await prefs.setString(_idKey, _id!);
    }

    _name = prefs.getString(_nameKey);
    if (_name == null) {
      final suffix = _id!.substring(0, 4);
      _name = Platform.isWindows ? 'Windows PC ($suffix)' : 'iPhone ($suffix)';
      await prefs.setString(_nameKey, _name!);
    }
  }

  Future<void> setName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
    _name = trimmed;
  }
}
