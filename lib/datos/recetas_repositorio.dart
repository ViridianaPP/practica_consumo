import 'package:recetario_utez/dominio/receta.dart';

/// Contrato de la fuente de recetas. La presentación solo conoce esto,
/// nunca Dio ni DummyJSON.
abstract class RecetasRepositorio {
  Future<PaginaRecetas> buscar({String texto = ''});
}
