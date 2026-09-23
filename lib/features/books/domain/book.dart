class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.description = '',
    this.coverUrl,
    this.genre = 'Fiction',
    this.progress = 0,
    this.isAudiobook = false,
    this.coverColor = 0xffefa936,
  });
  final int id;
  final String title;
  final String author;
  final String description;
  final String? coverUrl;
  final String genre;
  final double progress;
  final bool isAudiobook;
  final int coverColor;
}
