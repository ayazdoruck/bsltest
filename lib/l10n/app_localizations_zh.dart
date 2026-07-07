// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTagline => '查找同一局域网内的附近设备，快速传输文件。';

  @override
  String get tabReceive => '接收';

  @override
  String get tabSend => '发送';

  @override
  String get tabSettings => '设置';

  @override
  String servicesFailedToStart(String error) {
    return '服务启动失败：$error';
  }

  @override
  String get myDevice => '我的设备';

  @override
  String get incomingFiles => '接收的文件';

  @override
  String get noIncomingFiles => '暂无接收的文件。';

  @override
  String get nearbyDevices => '附近的设备';

  @override
  String get searchingForDevices => '正在搜索同一网络中的其他设备……';

  @override
  String get outgoingTransfers => '传输记录';

  @override
  String get noTransfersYet => '暂无传输记录。';

  @override
  String diagnosticsLine(
    String ip,
    String sent,
    String received,
    String scans,
    String error,
  ) {
    return '我的 IP：$ip | 已发送：$sent | 已接收：$received | 扫描次数：$scans | 错误：$error';
  }

  @override
  String get noneError => '无';

  @override
  String get deviceName => '设备名称';

  @override
  String get deviceNameHelp => '其他设备将以此名称识别您。';

  @override
  String get deviceNameUpdated => '设备名称已更新。';

  @override
  String get saveLocation => '保存位置';

  @override
  String get chooseFolder => '选择文件夹';

  @override
  String get resetToDefault => '恢复默认';

  @override
  String get defaultDownloads => '默认（下载文件夹）';

  @override
  String get iosFixedLocationInfo => '文件保存在应用内部（可通过“文件”应用中的 Bslend 文件夹访问）。';

  @override
  String get language => '语言';

  @override
  String get incomingFileTitle => '收到文件';

  @override
  String incomingFileFrom(String name) {
    return '$name 想要向您发送一个文件：';
  }

  @override
  String get reject => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get statusAwaitingApproval => '等待批准……';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusRejected => '已拒绝';

  @override
  String get statusTimedOut => '已超时';

  @override
  String statusFailed(String error) {
    return '错误：$error';
  }

  @override
  String get codedBy => '由 ';

  @override
  String sendToPeer(String name) {
    return '发送给 $name';
  }

  @override
  String get pickFile => '选择文件';

  @override
  String get pickFromGallery => '从相册选择';

  @override
  String get takePhoto => '拍照';

  @override
  String get preparingServer => '正在准备您的服务器……';

  @override
  String get retry => '重试';
}
