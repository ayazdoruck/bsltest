import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Find nearby devices on the same local network and transfer files fast.'**
  String get appTagline;

  /// No description provided for @tabReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get tabReceive;

  /// No description provided for @tabSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get tabSend;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @servicesFailedToStart.
  ///
  /// In en, this message translates to:
  /// **'Services failed to start: {error}'**
  String servicesFailedToStart(String error);

  /// No description provided for @myDevice.
  ///
  /// In en, this message translates to:
  /// **'My Device'**
  String get myDevice;

  /// No description provided for @incomingFiles.
  ///
  /// In en, this message translates to:
  /// **'Incoming Files'**
  String get incomingFiles;

  /// No description provided for @noIncomingFiles.
  ///
  /// In en, this message translates to:
  /// **'No incoming files yet.'**
  String get noIncomingFiles;

  /// No description provided for @nearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Nearby Devices'**
  String get nearbyDevices;

  /// No description provided for @searchingForDevices.
  ///
  /// In en, this message translates to:
  /// **'Searching for other devices on the same network...'**
  String get searchingForDevices;

  /// No description provided for @outgoingTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get outgoingTransfers;

  /// No description provided for @noTransfersYet.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet.'**
  String get noTransfersYet;

  /// No description provided for @diagnosticsLine.
  ///
  /// In en, this message translates to:
  /// **'My IP: {ip} | Sent: {sent} | Received: {received} | Scans: {scans} | Error: {error}'**
  String diagnosticsLine(
    String ip,
    String sent,
    String received,
    String scans,
    String error,
  );

  /// No description provided for @noneError.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get noneError;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @deviceNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Other devices will see you by this name.'**
  String get deviceNameHelp;

  /// No description provided for @deviceNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Device name updated.'**
  String get deviceNameUpdated;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get chooseFolder;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @defaultDownloads.
  ///
  /// In en, this message translates to:
  /// **'Default (Downloads)'**
  String get defaultDownloads;

  /// No description provided for @iosFixedLocationInfo.
  ///
  /// In en, this message translates to:
  /// **'Files are stored inside the app (accessible via the Files app under Bslend).'**
  String get iosFixedLocationInfo;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @incomingFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming File'**
  String get incomingFileTitle;

  /// No description provided for @incomingFileFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to send you a file:'**
  String incomingFileFrom(String name);

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @statusAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval...'**
  String get statusAwaitingApproval;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get statusTimedOut;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String statusFailed(String error);

  /// No description provided for @codedBy.
  ///
  /// In en, this message translates to:
  /// **'coded by '**
  String get codedBy;

  /// No description provided for @sendToPeer.
  ///
  /// In en, this message translates to:
  /// **'Send to {name}'**
  String sendToPeer(String name);

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get pickFile;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @preparingServer.
  ///
  /// In en, this message translates to:
  /// **'Preparing your server...'**
  String get preparingServer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
