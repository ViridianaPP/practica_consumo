import 'package:flutter/material.dart';
import 'package:recetario_utez/dominio/receta.dart';

/// Tarjeta de una receta: nombre, cocina · dificultad, tiempo y porciones,
/// calificación con un decimal y el aviso Rápida cuando aplica.
class TarjetaReceta extends StatelessWidget {
  const TarjetaReceta({super.key, required this.receta});

  final Receta receta;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    receta.nombre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (receta.esRapida)
                  const Chip(label: Text('Rápida'), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 4),
            Text('${receta.cocina} · ${receta.dificultad.etiqueta}'),
            const SizedBox(height: 4),
            Text(
              'Tiempo: ${receta.tiempoTotal} min · Porciones: ${receta.porciones}',
            ),
            const SizedBox(height: 4),
            Text('Calificación: ${receta.calificacion.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}
