import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/auth_screens.dart';
import '../../features/books/presentation/screens/book_screens.dart';
import '../../features/profile/presentation/screens/profile_screens.dart';
import '../../features/community/presentation/screens/community_screens.dart';
import '../../features/rewards/presentation/screens/reward_screens.dart';
import '../../features/ai/presentation/screens/ai_screens.dart';
import '../../features/notifications/presentation/screens/notification_screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
    GoRoute(
      path: '/filters',
      builder: (_, __) => const AdvancedFiltersScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (_, state) =>
          SearchResultsScreen(query: state.uri.queryParameters['q'] ?? ''),
    ),
    GoRoute(
      path: '/books/:id',
      builder: (_, state) => BookDetailsScreen(
        bookId: int.tryParse(state.pathParameters['id'] ?? '') ?? 1,
      ),
    ),
    GoRoute(
      path: '/reader/:id',
      builder: (_, state) => ReaderScreen(
        bookId: int.tryParse(state.pathParameters['id'] ?? '') ?? 1,
      ),
    ),
    GoRoute(path: '/audiobooks', builder: (_, __) => const AudiobooksScreen()),
    GoRoute(
      path: '/audiobook/player',
      builder: (_, __) => const AudiobookPlayerScreen(),
    ),
    GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: '/history', builder: (_, __) => const ReadingHistoryScreen()),
    GoRoute(
      path: '/analytics',
      builder: (_, __) => const ReadingAnalyticsScreen(),
    ),
    GoRoute(path: '/community', builder: (_, __) => const CommunityHubScreen()),
    GoRoute(
      path: '/community/group',
      builder: (_, __) => const GroupDetailsScreen(),
    ),
    GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/voice-chat', builder: (_, __) => const VoiceChatScreen()),
    GoRoute(path: '/study-room', builder: (_, __) => const StudyRoomScreen()),
    GoRoute(path: '/ai', builder: (_, __) => const AIAssistantScreen()),
    GoRoute(
      path: '/ai/voice',
      builder: (_, __) => const AIVoiceAssistantScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
    GoRoute(path: '/rewards/ad', builder: (_, __) => const RewardedAdScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(
      path: '/settings/theme',
      builder: (_, __) => const ThemeSelectionScreen(),
    ),
    GoRoute(
      path: '/settings/language',
      builder: (_, __) => const LanguageSelectionScreen(),
    ),
  ],
);
