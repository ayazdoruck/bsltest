// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTagline =>
      'Находите устройства в той же локальной сети и быстро передавайте файлы.';

  @override
  String get getStarted => 'Начать';

  @override
  String get tabReceive => 'Получить';

  @override
  String get tabSend => 'Отправить';

  @override
  String get tabSettings => 'Настройки';

  @override
  String servicesFailedToStart(String error) {
    return 'Не удалось запустить службы: $error';
  }

  @override
  String get myDevice => 'Мое устройство';

  @override
  String get incomingFiles => 'Входящие файлы';

  @override
  String get noIncomingFiles => 'Пока нет входящих файлов.';

  @override
  String get nearbyDevices => 'Устройства поблизости';

  @override
  String get searchingForDevices => 'Поиск других устройств в той же сети...';

  @override
  String get outgoingTransfers => 'Передачи';

  @override
  String get noTransfersYet => 'Пока нет передач.';

  @override
  String diagnosticsLine(
    String ip,
    String sent,
    String received,
    String scans,
    String error,
  ) {
    return 'Мой IP: $ip | Отправлено: $sent | Получено: $received | Сканирований: $scans | Ошибка: $error';
  }

  @override
  String get noneError => 'нет';

  @override
  String get deviceName => 'Имя устройства';

  @override
  String get deviceNameHelp =>
      'Другие устройства будут видеть вас под этим именем.';

  @override
  String get deviceNameUpdated => 'Имя устройства обновлено.';

  @override
  String get saveLocation => 'Место сохранения';

  @override
  String get chooseFolder => 'Выбрать папку';

  @override
  String get resetToDefault => 'Сбросить по умолчанию';

  @override
  String get defaultDownloads => 'По умолчанию (Загрузки)';

  @override
  String get iosFixedLocationInfo =>
      'Файлы хранятся внутри приложения (доступны через приложение «Файлы» в разделе Bslend).';

  @override
  String get language => 'Язык';

  @override
  String get incomingFileTitle => 'Входящий файл';

  @override
  String incomingFileFrom(String name) {
    return '$name хочет отправить вам файл:';
  }

  @override
  String get reject => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String get statusAwaitingApproval => 'Ожидание подтверждения...';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get statusTimedOut => 'Истекло время ожидания';

  @override
  String statusFailed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get codedBy => 'разработано ';

  @override
  String sendToPeer(String name) {
    return 'Отправить на $name';
  }

  @override
  String get pickFile => 'Выбрать файл';

  @override
  String get pickFromGallery => 'Выбрать из галереи';

  @override
  String get takePhoto => 'Сделать фото';
}
