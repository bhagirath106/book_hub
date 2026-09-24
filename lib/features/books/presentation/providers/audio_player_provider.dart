import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/book.dart';

class AudioPlayerState {
  final Book? currentBook;
  final List<AudiobookTrack> tracks;
  final int currentTrackIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;

  const AudioPlayerState({
    this.currentBook,
    this.tracks = const [],
    this.currentTrackIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
  });

  AudiobookTrack? get currentTrack {
    if (tracks.isNotEmpty && currentTrackIndex < tracks.length) {
      return tracks[currentTrackIndex];
    }
    return null;
  }

  AudioPlayerState copyWith({
    Book? currentBook,
    List<AudiobookTrack>? tracks,
    int? currentTrackIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
  }) {
    return AudioPlayerState(
      currentBook: currentBook ?? this.currentBook,
      tracks: tracks ?? this.tracks,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  void _init() {
    _player.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    _player.onPlayerStateChanged.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState == PlayerState.playing,
        isLoading: false,
      );
    });
  }

  Future<void> loadAudiobook(Book book) async {
    state = state.copyWith(
      currentBook: book,
      tracks: book.tracks,
      currentTrackIndex: 0,
      position: Duration.zero,
      duration: Duration.zero,
      isLoading: true,
    );

    if (book.tracks.isNotEmpty && book.tracks.first.audioUrl.isNotEmpty) {
      await playTrack(0);
    } else if (book.audioUrl != null && book.audioUrl!.isNotEmpty) {
      await _player.play(UrlSource(book.audioUrl!));
    }
  }

  Future<void> playTrack(int index) async {
    if (index < 0 || index >= state.tracks.length) return;

    final track = state.tracks[index];
    state = state.copyWith(
      currentTrackIndex: index,
      isLoading: true,
      position: Duration.zero,
    );

    if (track.audioUrl.isNotEmpty) {
      await _player.play(UrlSource(track.audioUrl));
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> playNext() async {
    if (state.currentTrackIndex + 1 < state.tracks.length) {
      await playTrack(state.currentTrackIndex + 1);
    }
  }

  Future<void> playPrevious() async {
    if (state.currentTrackIndex - 1 >= 0) {
      await playTrack(state.currentTrackIndex - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier();
    });
