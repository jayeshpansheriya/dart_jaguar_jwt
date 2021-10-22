import 'package:dotenv/dotenv.dart' as dotenv;
import 'dart:io';

abstract class Config {
  static Map<String, dynamic> get _env => dotenv.env ?? {};

  static int get port => int.tryParse(_env['PORT']) ?? 3000;

  static String get secret => _env['JWT_AUTH_SECRET'] ?? '';

  static Future<void> init() async {
    var filename = (await File.fromUri(Uri.parse('.env')).exists())
        ? '.env'
        : '.env.example';
    return dotenv.load(filename);
  }
}
