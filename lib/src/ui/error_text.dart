import 'dart:io';

String friendlyErrorText(Object error) {
  if (error is SocketException) return 'No connection';
  if (error is HandshakeException) return 'No connection';
  if (error is NoConnectionException) return 'No connection';
  if (error is SessionExpiredException) return 'Session expired';
  return error.toString();
}

class NoConnectionException implements Exception {
  const NoConnectionException();
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}
