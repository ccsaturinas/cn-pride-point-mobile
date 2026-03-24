import 'dart:io';

import 'package:http/http.dart';

String friendlyErrorText(Object error) {
  if (error is SocketException) return 'No connection';
  if (error is HandshakeException) return 'No connection';
  if (error is ClientException) return 'No connection';
  if (error is NoConnectionException) return 'No connection';
  if (error is SessionExpiredException) return 'Session expired';
  final text = error.toString();
  if (text.contains('SocketException')) return 'No connection';
  if (text.contains('Connection refused')) return 'No connection';
  return error.toString();
}

class NoConnectionException implements Exception {
  const NoConnectionException();
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}
