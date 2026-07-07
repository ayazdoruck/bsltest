// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline =>
      'Find nearby devices on the same local network and transfer files fast.';

  @override
  String get tabReceive => 'Receive';

  @override
  String get tabSend => 'Send';

  @override
  String get tabSettings => 'Settings';

  @override
  String servicesFailedToStart(String error) {
    return 'Services failed to start: $error';
  }

  @override
  String get myDevice => 'My Device';

  @override
  String get incomingFiles => 'Incoming Files';

  @override
  String get noIncomingFiles => 'No incoming files yet.';

  @override
  String get nearbyDevices => 'Nearby Devices';

  @override
  String get searchingForDevices =>
      'Searching for other devices on the same network...';

  @override
  String get outgoingTransfers => 'Transfers';

  @override
  String get noTransfersYet => 'No transfers yet.';

  @override
  String diagnosticsLine(
    String ip,
    String sent,
    String received,
    String scans,
    String error,
  ) {
    return 'My IP: $ip | Sent: $sent | Received: $received | Scans: $scans | Error: $error';
  }

  @override
  String get noneError => 'none';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceNameHelp => 'Other devices will see you by this name.';

  @override
  String get deviceNameUpdated => 'Device name updated.';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get chooseFolder => 'Choose Folder';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get defaultDownloads => 'Default (Downloads)';

  @override
  String get iosFixedLocationInfo =>
      'Files are stored inside the app (accessible via the Files app under Bslend).';

  @override
  String get language => 'Language';

  @override
  String get incomingFileTitle => 'Incoming File';

  @override
  String incomingFileFrom(String name) {
    return '$name wants to send you a file:';
  }

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get statusAwaitingApproval => 'Waiting for approval...';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusTimedOut => 'Timed out';

  @override
  String statusFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get codedBy => 'coded by ';

  @override
  String sendToPeer(String name) {
    return 'Send to $name';
  }

  @override
  String get pickFile => 'Choose File';

  @override
  String get pickFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get preparingServer => 'Preparing your server...';

  @override
  String get retry => 'Retry';
}
