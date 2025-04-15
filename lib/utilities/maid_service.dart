part of 'package:maid/main.dart';

class MaidService {
  static String get type => '_$typeName._$protocol';

  /// The service type name.
  static const String typeName = 'MaidService';

  /// The service type.
  static const String protocol = 'tcp';

  /// The service port.
  static const int port = 3410;

  /// The "OS" attribute.
  static const String attributeOs = 'os';

  /// The "ID" attribute.
  static const String attributeId = 'id';

  /// The default app service.
  static late BonsoirService _service;

  /// Returns the default app service instance.
  static BonsoirService get service => _service;

  /// Initializes the Bonsoir service instance.
  static Future initialize() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String name;
    String os;
    if (Platform.isAndroid) {
      name = (await deviceInfo.androidInfo).model;
      os = 'Android';
    } else if (Platform.isIOS) {
      name = (await deviceInfo.iosInfo).localizedModel;
      os = 'iOS';
    } else if (Platform.isMacOS) {
      name = (await deviceInfo.macOsInfo).computerName;
      os = 'macOS';
    } else if (Platform.isWindows) {
      name = (await deviceInfo.windowsInfo).computerName;
      os = 'Windows';
    } else if (Platform.isLinux) {
      name = (await deviceInfo.linuxInfo).name;
      os = 'Linux';
    } else {
      name = 'Flutter';
      os = 'Unknown';
    }

    _service = BonsoirService(
      name: name,
      type: type,
      port: port,
      attributes: {attributeOs: os, attributeId: math.Random().nextInt(2^62).toUnsigned(20).toRadixString(16)},
    );
  }
}