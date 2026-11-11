import 'package:dio/dio.dart';
import 'package:recetario_utez/dominio/falla_red.dart';

/// Traduce un [DioException] a la falla de dominio que le toca:
/// - cualquier timeout → [TiempoAgotado];
/// - badResponse con código >= 500 → [ErrorDelServidor], otro código →
///   [PeticionRechazada];
/// - unknown cuya causa es FormatException → [RespuestaInvalida];
/// - todo lo demás → [SinConexion].
FallaRed traducirError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TiempoAgotado();
    case DioExceptionType.badResponse:
      final codigo = e.response?.statusCode ?? 0;
      return codigo >= 500
          ? ErrorDelServidor(codigo)
          : PeticionRechazada(codigo);
    case DioExceptionType.unknown:
      if (e.error is FormatException) return const RespuestaInvalida();
      return const SinConexion();
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.connectionError:
      return const SinConexion();
  }
}
