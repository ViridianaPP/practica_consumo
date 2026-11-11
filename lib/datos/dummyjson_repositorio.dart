import 'package:dio/dio.dart';
import 'package:recetario_utez/datos/recetas_json.dart';
import 'package:recetario_utez/datos/recetas_repositorio.dart';
import 'package:recetario_utez/datos/traducir_error.dart';
import 'package:recetario_utez/dominio/falla_red.dart';
import 'package:recetario_utez/dominio/receta.dart';

const recetasPorPagina = 10;

/// Implementación del contrato [RecetasRepositorio] sobre DummyJSON.
/// El texto de la persona viaja siempre en la query, nunca en la URL.
class DummyJsonRepositorio implements RecetasRepositorio {
  DummyJsonRepositorio(this._dio);

  final Dio _dio;

  @override
  Future<PaginaRecetas> buscar({String texto = ''}) async {
    final limpio = texto.trim();
    try {
      final respuesta =
          limpio.isEmpty
              ? await _dio.get(
                '/recipes',
                queryParameters: {'limit': recetasPorPagina},
              )
              : await _dio.get(
                '/recipes/search',
                queryParameters: {'q': limpio, 'limit': recetasPorPagina},
              );
      final cuerpo = respuesta.data;
      if (cuerpo is! Map<String, dynamic>) {
        throw const RespuestaInvalida();
      }
      return paginaDesdeJson(cuerpo);
    } on DioException catch (e) {
      throw traducirError(e);
    } on FormatException {
      throw const RespuestaInvalida();
    }
  }
}
