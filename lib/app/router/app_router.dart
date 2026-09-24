import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/auth_screens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/books/presentation/screens/book_screens.dart';
import '../../features/profile/presentation/screens/profile_screens.dart';
import '../../features/community/presentation/screens/community_screens.dart';
import '../../features/rewards/presentation/screens/reward_screens.dart';
import '../../features/ai/presentation/screens/ai_screens.dart';
import '../../features/notifications/presentation/screens/notification_screens.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthPath =
          state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthPath) {
        return '/auth/login';
      }

      if (isLoggedIn &&
          (state.matchedLocation == '/auth/login' ||
              state.matchedLocation == '/auth/register' ||
              state.matchedLocation == '/auth/forgot-password')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const AdvancedFiltersScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) =>
            SearchResultsScreen(query: state.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: '/books/:id',
        builder: (context, state) =>
            BookDetailsScreen(bookId: state.pathParameters['id'] ?? '1'),
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (context, state) =>
            ReaderScreen(bookId: state.pathParameters['id'] ?? '1'),
      ),
      GoRoute(
        path: '/audiobooks',
        builder: (context, state) => const AudiobooksScreen(),
      ),
      GoRoute(
        path: '/audiobook/player',
        builder: (context, state) => const AudiobookPlayerScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const ReadingHistoryScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const ReadingAnalyticsScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityHubScreen(),
      ),
      GoRoute(
        path: '/community/group',
        builder: (context, state) => const GroupDetailsScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/voice-chat',
        builder: (context, state) => const VoiceChatScreen(),
      ),
      GoRoute(
        path: '/study-room',
        builder: (context, state) => const StudyRoomScreen(),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/ai/voice',
        builder: (context, state) => const AIVoiceAssistantScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/rewards/ad',
        builder: (context, state) => const RewardedAdScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/theme',
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
    ],
  );
});

// Fallback static router instance for direct imports if any
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
);
