// estado_canvas.dart — fuente única del enum (elimina el que estaba en mecanica_provider.dart)
enum EstadoCanvas {
  vacio,       // Sin elementos en el lienzo
  dibujando,   // Elementos presentes, sin petición en vuelo
  calculando,  // Petición HTTP en vuelo hacia la API
  verificado,  // Resultados de la API cargados exitosamente
  error        // Falló la conexión con la API
}