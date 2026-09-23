import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
