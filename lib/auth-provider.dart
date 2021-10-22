import 'dart:async';
import 'dart:convert';

import 'package:dart_jaguar_jwt/config.dart';
import 'package:dart_jaguar_jwt/hash.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

abstract class AuthProvider {
  static final JsonDecoder _decoder = const JsonDecoder();

  static List<Map<String, String>> users = [
    {'username': 'test', 'password': Hash.create('insecure')},
    {'username': 'beep', 'password': Hash.create('beepboop')}
  ];

  static bool _check(Map<String, String> user, Map<String, String> creds) =>
      (user['username'] == creds['username'] &&
          user['password'] == creds['password']);

  static FutureOr<Response> handle(Request request) async =>
      (request.url.toString() == 'login')
          ? AuthProvider.auth(request)
          : AuthProvider.verify(request);

  static FutureOr<Response> auth(Request request) async {
    try {
      dynamic data = _decoder.convert(await request.readAsString());
      String user = data['username'];
      var hash = Hash.create(data['password']);

      var creds = <String, String>{'username': user, 'password': hash};
      var index = users.indexWhere((user) => _check(user, creds));
      if (index == -1) {
        throw Exception();
      }

      var claim = JwtClaim(
        subject: user,
        issuer: 'Jayesh',
        audience: ['example.com'],
      );

      var token = issueJwtHS256(claim, Config.secret);
      return Response.ok(token);
    } catch (e) {
      return Response(401, body: 'Incorrect username/password');
    }
  }

  static FutureOr<Response> verify(Request request) async {
    try {
      var token = request.headers['Authorization'].replaceAll('Bearer ', '');
      var claim = verifyJwtHS256Signature(token, Config.secret);
      claim.validate(issuer: 'ACME Widgets Corp', audience: 'example.com');
      return null;
    } catch (e) {
      return Response.forbidden('Authorization rejected');
    }
  }
}
