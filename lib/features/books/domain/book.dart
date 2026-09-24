class AudiobookTrack {
  const AudiobookTrack({
    required this.id,
    required this.title,
    required this.trackNumber,
    required this.duration,
    required this.audioUrl,
  });

  final String id;
  final String title;
  final int trackNumber;
  final String duration;
  final String audioUrl;
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.description = '',
    this.coverUrl,
    this.genre = 'Fiction',
    this.progress = 0.0,
    this.isAudiobook = false,
    this.coverColor = 0xffefa936,
    this.isbn10,
    this.isbn13,
    this.publisher,
    this.publishedDate,
    this.pageCount,
    this.language,
    this.source = 'open_library',
    this.sourceId,
    this.ebookUrl,
    this.isEbookAvailable = false,
    this.audioUrl,
    this.tracks = const [],
  });

  final dynamic id;
  final String title;
  final String author;
  final String description;
  final String? coverUrl;
  final String genre;
  final double progress;
  final bool isAudiobook;
  final int coverColor;
  final String? isbn10;
  final String? isbn13;
  final String? publisher;
  final String? publishedDate;
  final int? pageCount;
  final String? language;
  final String source;
  final String? sourceId;
  final String? ebookUrl;
  final bool isEbookAvailable;
  final String? audioUrl;
  final List<AudiobookTrack> tracks;
}
