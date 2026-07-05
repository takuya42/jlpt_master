import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_repository.dart';
import '../../domain/home_content.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const BundledHomeRepository();
});

final homeContentProvider = FutureProvider<HomeContent>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchHomeContent();
});
