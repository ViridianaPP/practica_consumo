import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Bitácora segura: registra una línea por petición, respuesta y error con
/// solo método, ruta (path), código, tipo de error y tiempo en ms.
/// Nunca escribe la query, los encabezados ni el cuerpo, para no filtrar
/// lo que la persona busca.
class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? developer.log;

  final void Function(String linea) _escribir;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // El cronómetro viaja con la petición para medir cuánto tarda.
    options.extra['cronometro'] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    _escribir('← ${response.statusCode} ${o.method} ${o.path} (${_ms(o)} ms)');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final codigo = err.response?.statusCode;
    _escribir(
      '✗ ${err.type.name}'
      '${codigo == null ? '' : ' $codigo'}'
      ' ${o.method} ${o.path} (${_ms(o)} ms)',
    );
    handler.next(err);
  }

  int _ms(RequestOptions options) {
    final cronometro = options.extra['cronometro'];
    if (cronometro is Stopwatch) return cronometro.elapsedMilliseconds;
    return 0;
  }
}
