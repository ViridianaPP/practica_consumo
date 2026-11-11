import 'package:dio/dio.dart';

import 'bitacora_interceptor.dart';

const urlDummyJson = 'https://dummyjson.com';

/// Crea el [Dio] para hablar con DummyJSON:
/// - baseUrl por HTTPS;
/// - timeouts prudentes (10 s para conectar y para recibir);
/// - la bitácora va primero y después los interceptores extra que reciba.
Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(BitacoraInterceptor());
  dio.interceptors.addAll(interceptores);
  return dio;
}
