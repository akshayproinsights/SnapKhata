// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/billing/presentation/screens/bill_review_screen.dart';
import '../../features/billing/presentation/screens/bill_summary_screen.dart';
import '../../features/billing/presentation/screens/order_detail_screen.dart';
import '../../features/billing/data/models/scanned_bill.dart' show ScannedBill;
import '../database/app_database.dart';
import '../../features/billing/presentation/screens/scan_screen.dart';
import '../../features/billing/presentation/screens/shop_profile_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/billing/presentation/screens/manual_bill_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// Route path constants.
class AppRoutes {
  AppRoutes._();
  static const String home = '/';
  static const String login = '/login';
  static const String scan = '/scan';
  static const String billReview = '/bill-review';
  static const String billSummary = '/bill-summary';
  static const String shopProfile = '/shop-profile';
  static const String customers = '/customers';
  static const String customerDetail = '/customer-detail';
  static const String orderDetail = '/order-detail';
  static const String manualBill = '/manual-bill';
}

/// GoRouter instance with auth-guard redirect.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isOnLogin) return AppRoutes.login;
      if (isLoggedIn && isOnLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.billReview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BillReviewScreen(
            initialBill: extra['bill'] as ScannedBill,
            imagePath: extra['imagePath'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.billSummary,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BillSummaryScreen(
            bill: extra['bill'] as ScannedBill,
            billId: extra['billId'] as int,
            isSynced: extra['isSynced'] as bool,
            imagePath: extra['imagePath'] as String,
            invoiceType: (extra['invoiceType'] as String?) ?? 'order_summary',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shopProfile,
        builder: (context, state) => const ShopProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final showPendingOnly = extra?['showPendingOnly'] == true;
          return CustomersScreen(showPendingOnly: showPendingOnly);
        },
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (context, state) {
          final bill = state.extra as Bill;
          return OrderDetailScreen(bill: bill);
        },
      ),
      GoRoute(
        path: AppRoutes.manualBill,
        builder: (context, state) => const ManualBillScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomerDetailScreen(
            phone: extra['phone'] as String?,
            displayName: extra['displayName'] as String,
          );
        },
      ),
    ],
  );
});
