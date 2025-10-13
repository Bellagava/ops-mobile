import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Para emulador Android
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // Para simulador iOS
      return 'http://localhost:3000';
    } else {
      // Para web ou desktop
      return 'http://localhost:3000';
    }
  }
}