class Constants {
  static const String baseUrl = 'https://news.freepi.io/wp-json/wp/v2';
  static const int perPage = 10;

  // 🔥 Palabras clave → ID real de categoría en WordPress
  static const Map<String, int> categoryMap = {
    'futbol': 3,
    'fútbol': 3,
    'deportes': 3,

    'tecnologia': 5,
    'tecnología': 5,

    'economia': 7,
    'economía': 7,

    'politica': 9,
    'política': 9,

    'salud': 11,
    'entretenimiento': 13,
  };
}
