import 'package:flutter/material.dart';
import 'package:recetario_utez/datos/recetas_repositorio.dart';
import 'package:recetario_utez/presentacion/recetas_pagina.dart';
import 'package:recetario_utez/presentacion/recetas_view_model.dart';

/// Raíz de la app: crea el ViewModel una sola vez con el repositorio que
/// recibe, lo libera en dispose y arma el MaterialApp.
class AppRecetario extends StatefulWidget {
  const AppRecetario({super.key, required this.repositorio});

  final RecetasRepositorio repositorio;

  @override
  State<AppRecetario> createState() => _AppRecetarioState();
}

class _AppRecetarioState extends State<AppRecetario> {
  late final RecetasViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RecetasViewModel(widget.repositorio);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario UTEZ',
      theme: ThemeData(useMaterial3: true),
      home: RecetasPagina(vm: _vm),
    );
  }
}
