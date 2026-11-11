# Evidencias — Recetario UTEZ

**Nombre:** Viridiana Portilla Palestina
**Matrícula:** I20233tn092
**Fecha:** 10/11/2026
**Dispositivo donde se probó:** Chrome (Windows)

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla (obligatorio, tolerado, valor por defecto) |
|---|---|---|---|
| id | Receta.id | int | obligatorio |
| name | Receta.nombre | String | obligatorio |
| cuisine | Receta.cocina | String | obligatorio |
| prepTimeMinutes | Receta.minutosPreparacion | int | obligatorio |
| cookTimeMinutes | Receta.minutosCoccion | int | obligatorio |
| servings | Receta.porciones | int | obligatorio |
| rating | Receta.calificacion | double | obligatorio; llega como int (5) o double (4.6) y se guarda siempre como double |
| difficulty | Receta.dificultad | Dificultad | tolerado: Easy → facil, Medium → media, Hard → dificil; cualquier otra cosa (o null) → desconocida |
| tags | Receta.etiquetas | List\<String\> | opcional: si falta → lista vacía; si no es lista o un elemento no es texto → FormatException |
| ingredients | Receta.ingredientes | List\<String\> | opcional: misma regla que tags |
| recipes | PaginaRecetas.recetas | List\<Receta\> | obligatorio; lista vacía es válida |
| total | PaginaRecetas.total | int | obligatorio |
| (los demás campos del JSON) | — | — | se ignoran |

## 2. Escenarios probados con el servicio real

| Escenario | Cómo lo provoqué | Qué vio la persona | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|---|---|---|---|
| Éxito | Busqué "chicken" con el botón Buscar recetas | El botón se desactivó, apareció el indicador de carga y luego 8 tarjetas con el encabezado "Mostrando 8 de 8 recetas · Rápidas: 1" | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (139 ms)` | capturas/exito.png | etapa3 "200 → PaginaRecetas" y etapa5 "texto + botón → indicador y botón apagado → tarjetas" |
| Vacío | Busqué "zzzz" | Mensaje: No encontramos recetas para "zzzz". | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (156 ms)` | capturas/vacio.png | etapa3 "200 sin resultados → página vacía" y etapa5 "vacío con texto dice qué se buscó" |
| Error del servidor | Cambio temporal A: interceptor que redirige a /http/503 y busqué cualquier cosa | Mensaje: El recetario no está disponible (503). Intenta más tarde. Y botón Reintentar | `→ GET /recipes/search`<br>`✗ badResponse 503 GET /http/503 (399 ms)` | capturas/error_servidor.png | etapa3 "503 → ErrorDelServidor(503)" |
| Sin red | Activa modo avión (o cambio temporal C) y busqué | Mensaje: Sin conexión. Revisa tu red e intenta de nuevo. Y botón Reintentar | `→ GET /recipes/search`<br>`✗ connectionError GET /recipes/search (108 ms)` | capturas/sin_red.png | etapa3 "sin red → SinConexion" y etapa5 "error → mensaje y Reintentar repite la misma búsqueda" |
| Tiempo agotado | Cambio temporal B: delay de 5000 ms y timeouts de 2 s | Mensaje: El recetario tardó demasiado en responder. Intenta de nuevo. Y botón Reintentar | `→ GET /recipes/search`<br>`✗ connectionTimeout GET /recipes/search (2036 ms)` | capturas/tiempo_agotado.png | etapa3 "connectTimeout → TiempoAgotado" y "receiveTimeout → TiempoAgotado" |

## 3. Preguntas de reflexión

1. **¿En qué se diferencian el escenario "Error del servidor" y "Sin red" desde el punto de vista de HTTP?**
   En el 503 sí hubo respuesta HTTP: la petición llegó al servidor y este contestó con un código de estado (503, servicio no disponible). En "Sin red" nunca existió una respuesta HTTP: la petición no salió del dispositivo o nunca llegó nada de vuelta, así que no hay código de estado. Por eso se traducen distinto: `ErrorDelServidor(503)` conserva el código, mientras que `SinConexion` no tiene código que guardar.

2. **¿Por qué "Vacío" no es un error?**
   Porque el servidor respondió 200 OK con un JSON válido cuyo arreglo `recipes` está vacío: la comunicación fue exitosa y el formato es correcto; simplemente no hubo coincidencias. Un error sería un código de error (5xx/4xx) o un JSON que no se puede interpretar; aquí el servidor cumplió su contrato.

3. **La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?**
   Porque la bitácora solo escribe método, ruta (`options.path`), código, tipo de error y tiempo; nunca lee `options.uri` ni `queryParameters`, que es donde viaja el texto (`/recipes/search?q=pasta`). Así la bitácora no filtra lo que la persona buscó.

4. **Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?**
   Solo `lib/datos/recetas_json.dart`, porque es el único archivo que conoce las llaves del JSON (el patrón de mapa con `'rating': num calificacion`). El dominio (`Receta`) ya recibe un `double calificacion` tipado, el repositorio solo entrega la página ya convertida y la UI solo muestra el dato: ninguna de esas capas sabe cómo se llama la llave en el JSON.
