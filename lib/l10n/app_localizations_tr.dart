// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTagline =>
      'Aynı yerel ağ üzerindeki cihazları bulup aralarında hızlı dosya aktarımı yapın.';

  @override
  String get getStarted => 'Başlayalım';

  @override
  String get tabReceive => 'Al';

  @override
  String get tabSend => 'Gönder';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String servicesFailedToStart(String error) {
    return 'Servisler başlatılamadı: $error';
  }

  @override
  String get myDevice => 'Cihazım';

  @override
  String get incomingFiles => 'Gelen Dosyalar';

  @override
  String get noIncomingFiles => 'Henüz gelen dosya yok.';

  @override
  String get nearbyDevices => 'Yakındaki Cihazlar';

  @override
  String get searchingForDevices =>
      'Aynı ağ üzerinde başka bir cihaz aranıyor...';

  @override
  String get outgoingTransfers => 'Transferler';

  @override
  String get noTransfersYet => 'Henüz bir transfer yok.';

  @override
  String diagnosticsLine(
    String ip,
    String sent,
    String received,
    String scans,
    String error,
  ) {
    return 'Benim IP: $ip | Gönderilen: $sent | Alınan: $received | Tarama: $scans | Hata: $error';
  }

  @override
  String get noneError => 'yok';

  @override
  String get deviceName => 'Cihaz Adı';

  @override
  String get deviceNameHelp => 'Diğer cihazlarda seni bu adla görürler.';

  @override
  String get deviceNameUpdated => 'Cihaz adı güncellendi.';

  @override
  String get saveLocation => 'Dosya Kayıt Konumu';

  @override
  String get chooseFolder => 'Klasör Seç';

  @override
  String get resetToDefault => 'Varsayılana Dön';

  @override
  String get defaultDownloads => 'Varsayılan (İndirilenler)';

  @override
  String get iosFixedLocationInfo =>
      'Dosyalar uygulama içinde saklanır (Dosyalar uygulamasından Bslend altında erişilebilir).';

  @override
  String get language => 'Dil';

  @override
  String get incomingFileTitle => 'Gelen Dosya';

  @override
  String incomingFileFrom(String name) {
    return '$name size bir dosya gönderiyor:';
  }

  @override
  String get reject => 'Reddet';

  @override
  String get accept => 'Kabul Et';

  @override
  String get statusAwaitingApproval => 'Onay bekleniyor...';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String get statusTimedOut => 'Zaman aşımı';

  @override
  String statusFailed(String error) {
    return 'Hata: $error';
  }

  @override
  String get codedBy => 'coded by ';

  @override
  String sendToPeer(String name) {
    return '$name adlı cihaza gönder';
  }

  @override
  String get pickFile => 'Dosya Seç';

  @override
  String get pickFromGallery => 'Galeriden Seç';

  @override
  String get takePhoto => 'Kamerayla Çek';
}
