import 'package:flutter/foundation.dart';
import 'package:recetario_utez/datos/recetas_repositorio.dart';
import 'package:recetario_utez/dominio/falla_red.dart';
import 'package:recetario_utez/dominio/receta.dart';
import 'package:recetario_utez/presentacion/mensajes.dart';

/// Estados excluyentes de la pantalla de recetas.
sealed class EstadoRecetas {
  const EstadoRecetas();
}

final class RecetasInicial extends EstadoRecetas {
  const RecetasInicial();
}

final class RecetasCargando extends EstadoRecetas {
  const RecetasCargando();
}

final class RecetasListas extends EstadoRecetas {
  const RecetasListas(this.recetas, this.total);

  final List<Receta> recetas;
  final int total;
}

final class RecetasVacias extends EstadoRecetas {
  const RecetasVacias(this.busqueda);

  final String busqueda;
}

final class RecetasFallidas extends EstadoRecetas {
  const RecetasFallidas(this.mensaje);

  final String mensaje;
}

/// Coordina la pantalla: le pide recetas al contrato [RecetasRepositorio] y
/// reparte estados excluyentes. No dibuja ni sabe de HTTP.
class RecetasViewModel extends ChangeNotifier {
  RecetasViewModel(this._repositorio);

  final RecetasRepositorio _repositorio;

  EstadoRecetas _estado = const RecetasInicial();
  String _ultimaBusqueda = '';
  bool _liberado = false;

  EstadoRecetas get estado => _estado;

  /// Derivado del estado: verdadero solo mientras se espera la respuesta.
  bool get cargando => _estado is RecetasCargando;

  /// El último texto buscado, ya sin espacios.
  String get ultimaBusqueda => _ultimaBusqueda;

  /// Derivado del estado: recetas rápidas del resultado; 0 si no hay.
  int get rapidas => switch (_estado) {
    RecetasListas(:final recetas) => recetas.where((r) => r.esRapida).length,
    _ => 0,
  };

  /// Busca con el texto de la persona. Si ya está cargando no hace nada.
  /// Avisa exactamente dos veces: al pasar a Cargando y al terminar.
  Future<void> buscar(String texto) async {
    if (cargando) return;
    _ultimaBusqueda = texto.trim();
    _estado = const RecetasCargando();
    _avisar();
    try {
      final pagina = await _repositorio.buscar(texto: _ultimaBusqueda);
      _estado =
          pagina.recetas.isEmpty
              ? RecetasVacias(_ultimaBusqueda)
              : RecetasListas(pagina.recetas, pagina.total);
    } on FallaRed catch (falla) {
      _estado = RecetasFallidas(mensajePara(falla));
    } catch (_) {
      _estado = const RecetasFallidas(mensajeInesperado);
    }
    _avisar();
  }

  /// Repite la última búsqueda tal cual.
  Future<void> reintentar() => buscar(_ultimaBusqueda);

  /// No avisa después de que la pantalla se cerró.
  void _avisar() {
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
