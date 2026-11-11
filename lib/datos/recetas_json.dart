import 'package:recetario_utez/dominio/receta.dart';

/// Traduce el texto de dificultad que manda DummyJSON.
/// Cualquier cosa que no sea Easy, Medium o Hard (incluido null o un número)
/// se trata como [Dificultad.desconocida]; nunca lanza.
Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida,
  };
}

/// Convierte un objeto JSON de receta en [Receta].
/// Los campos obligatorios (id, name, cuisine, prepTimeMinutes,
/// cookTimeMinutes, servings, rating) deben existir y tener el tipo correcto;
/// si no, lanza [FormatException]. tags e ingredients son opcionales.
Receta recetaDesdeJson(Map<String, dynamic> json) {
  if (json case {
    'id': int id,
    'name': String nombre,
    'cuisine': String cocina,
    'prepTimeMinutes': int minutosPreparacion,
    'cookTimeMinutes': int minutosCoccion,
    'servings': int porciones,
    // rating llega a veces como entero (5) y a veces con decimales (4.6).
    'rating': num calificacion,
  }) {
    return Receta(
      id: id,
      nombre: nombre,
      cocina: cocina,
      dificultad: dificultadDesdeTexto(json['difficulty']),
      minutosPreparacion: minutosPreparacion,
      minutosCoccion: minutosCoccion,
      porciones: porciones,
      calificacion: calificacion.toDouble(),
      etiquetas: listaDeTextos(json['tags']),
      ingredientes: listaDeTextos(json['ingredients']),
    );
  }
  throw const FormatException('La receta no tiene los campos obligatorios.');
}

/// Convierte un objeto JSON de página ({recipes, total}) en [PaginaRecetas].
/// Cada elemento de recipes debe ser un objeto convertible con
/// [recetaDesdeJson]. Una lista vacía es válida.
PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  if (json case {'recipes': List crudas, 'total': int total}) {
    final recetas = <Receta>[];
    for (final elemento in crudas) {
      if (elemento is! Map<String, dynamic>) {
        throw const FormatException('Un elemento de recipes no es objeto.');
      }
      recetas.add(recetaDesdeJson(elemento));
    }
    return PaginaRecetas(recetas: recetas, total: total);
  }
  throw const FormatException('La página no tiene recipes y total.');
}

/// Lista de textos opcional: si falta la llave regresa vacía; si existe pero
/// no es lista, o algún elemento no es texto, lanza [FormatException].
List<String> listaDeTextos(Object? valor) {
  if (valor == null) return const [];
  if (valor is! List) {
    throw const FormatException('Se esperaba una lista de textos.');
  }
  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw const FormatException('Un elemento de la lista no es texto.');
    }
    textos.add(elemento);
  }
  return textos;
}
