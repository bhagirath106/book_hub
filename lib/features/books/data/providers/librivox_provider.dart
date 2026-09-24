import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/book.dart';

class LibriVoxProvider {
  final http.Client _client;
  LibriVoxProvider({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://librivox.org/api/feed';

  Future<List<Book>> searchAudiobooks(String query) async {
    try {
      final String url;
      if (query.trim().isEmpty) {
        url = '$baseUrl/audiobooks?format=json&limit=20';
      } else {
        url =
            '$baseUrl/audiobooks?title=${Uri.encodeQueryComponent(query)}&format=json';
      }

      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final books = data['books'] as List<dynamic>? ?? [];

        return books
            .map((item) => _mapLibriVoxToBook(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<AudiobookTrack>> getAudioTracks(String audiobookId) async {
    try {
      final cleanId = audiobookId.replaceAll('librivox_', '');
      final url = '$baseUrl/audiotracks?audiobook_id=$cleanId&format=json';

      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final sectionTracks = data['section_tracks'] as List<dynamic>? ?? [];

        return sectionTracks
            .map((track) => _mapTrack(track as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  AudiobookTrack _mapTrack(Map<String, dynamic> track) {
    final sectionNumber = track['section_number']?.toString() ?? '1';
    final title = track['title']?.toString() ?? 'Track $sectionNumber';
    final playUrl =
        track['listen_url']?.toString() ??
        track['url_zip_file']?.toString() ??
        '';

    return AudiobookTrack(
      id: track['id']?.toString() ?? sectionNumber,
      title: title,
      trackNumber: int.tryParse(sectionNumber) ?? 1,
      duration: track['playtime']?.toString() ?? '0:00',
      audioUrl: playUrl,
    );
  }

  Book _mapLibriVoxToBook(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Untitled Audiobook';

    final authorsList = item['authors'] as List<dynamic>?;
    final authorNames = authorsList != null
        ? authorsList
              .map(
                (a) =>
                    '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim(),
              )
              .where((name) => name.isNotEmpty)
              .toList()
        : <String>[];
    final author = authorNames.isNotEmpty
        ? authorNames.join(', ')
        : 'LibriVox Volunteers';

    final description =
        item['description']?.toString() ??
        'Public-domain audiobook recorded by LibriVox volunteers.';

    final audioUrl =
        item['url_zip_file']?.toString() ?? item['url_iarchive']?.toString();

    final genresList = item['genres'] as List<dynamic>?;
    final genre = genresList != null && genresList.isNotEmpty
        ? genresList.first['name']?.toString() ?? 'Audiobook'
        : 'Audiobook';

    final language = item['language']?.toString() ?? 'English';

    return Book(
      id: 'librivox_$id',
      title: title,
      author: author,
      description: _cleanHtml(description),
      genre: genre,
      language: language,
      isAudiobook: true,
      source: 'librivox',
      sourceId: id,
      audioUrl: audioUrl,
    );
  }

  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
