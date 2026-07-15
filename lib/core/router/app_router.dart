import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_providers.dart';
import '../auth/role.dart';
import 'go_router_refresh_stream.dart';
import '../../features/auth/presentation/admin_home_screen.dart';
import '../../features/auth/presentation/kasir_home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/category_manager_screen.dart';
import '../../features/products/presentation/product_form_screen.dart';
import '../../features/products/presentation/product_list_screen.dart';
import '../../features/pos/presentation/cart_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/reports/presentation/sales_report_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) async {
      final loggingIn = state.matchedLocation == '/login';
      final session = authRepository.currentSession;

      if (session == null) {
        return loggingIn ? null : '/login';
      }

      final profile = await ref.read(currentProfileProvider.future);
      final role = profile?.role ?? await authRepository.getCachedRole() ?? AppRole.kasir;
      final home = role == AppRole.admin ? '/admin' : '/kasir';

      const adminOnlyPaths = ['/admin', '/categories'];
      if (loggingIn) return home;
      if (adminOnlyPaths.contains(state.matchedLocation) && role != AppRole.admin) return home;

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminHomeScreen()),
      GoRoute(path: '/kasir', builder: (context, state) => const KasirHomeScreen()),
      GoRoute(path: '/products', builder: (context, state) => const ProductListScreen()),
      GoRoute(path: '/products/new', builder: (context, state) => const ProductFormScreen()),
      GoRoute(
        path: '/products/:id/edit',
        builder: (context, state) => ProductFormScreen(existing: state.extra as Product?),
      ),
      GoRoute(path: '/categories', builder: (context, state) => const CategoryManagerScreen()),
      GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
      GoRoute(path: '/pos/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const SalesReportScreen()),
    ],
  );
});
