import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_jaguar_jwt/auth-provider.dart';
import 'package:dart_jaguar_jwt/config.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> args) async => Server.start(args);

abstract class Server {
  static bool debug;

  static Response _echo(Request request) =>
      Response.ok('Authorization OK for "${request.url}"');

  static Future<void> start(List<String> args) async {
    await Config.init();

    var parser = ArgParser()
      ..addOption('debug', abbr: 'd', defaultsTo: 'false');
    var result = parser.parse(args);

    debug = (result['debug'] == 'true');
    if (debug) {
      stdout.writeln('Debug output is enabled');
    }

    var auth = createMiddleware(requestHandler: AuthProvider.handle);
    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(auth)
        .addHandler(_echo);

    var server = await io.serve(handler, 'localhost', Config.port);
    print('Serving at http://${server.address.host}:${server.port}');
  }
}
