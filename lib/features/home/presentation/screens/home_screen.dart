// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../billing/presentation/providers/bill_provider.dart';
import '../../../billing/presentation/providers/shop_profile_provider.dart';
import '../../../billing/data/repositories/shop_profile_repository.dart';
import '../../../customers/presentation/providers/customer_provider.dart';

// ─────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────

const _kGreen = Color(0xFF1B8A2A);
const _kGreenBg = Color(0xFFE8F5E9);
const _kRed = Color(0xFFC62828);
const _kRedBg = Color(0xFFFFEBEE);
const _kBrandPrimary = Color(0xFF3949AB);

// ─────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final shopProfile = ref.watch(shopProfileProvider);
    final theme = Theme.of(context);

    final shopName = shopProfile.whenOrNull(
          data: (profile) => profile?.shopName,
        ) ??
        '';

    final displayName =
        shopName.isNotEmpty ? shopName : 'My Shop';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: GestureDetector(
          onTap: () => _showRenameDialog(context, ref, displayName),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Open notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/shop-profile'),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => Column(
          children: [
            // ── Quick Links ──────────────────────────────────
            _QuickLinksBar(ref: ref),

            // ── Dual-Tab Section ─────────────────────────────
            const Expanded(child: _HomeTabs()),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 52,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/scan'),
          backgroundColor: _kBrandPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.camera_alt_rounded, size: 22),
          label: Text(
            'Snap New Order',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(
      text: currentName == 'My Shop' ? '' : currentName,
    );
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Rename Your Shop',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Ganesh Kirana Store',
            prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: (_) => _saveShopName(ctx, ref, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _saveShopName(ctx, ref, controller.text),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveShopName(BuildContext ctx, WidgetRef ref, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Shop name cannot be empty')),
      );
      return;
    }
    Navigator.pop(ctx);

    final existing = ref.read(shopProfileProvider).valueOrNull;
    final updated = existing != null
        ? existing.copyWith(shopName: trimmed)
        : ShopProfileData(shopName: trimmed);
    ref.read(shopProfileProvider.notifier).save(updated);
  }
}

// ─────────────────────────────────────────────────────────────
// Quick Links Bar
// ─────────────────────────────────────────────────────────────

class _QuickLinksBar extends StatelessWidget {
  final WidgetRef ref;
  const _QuickLinksBar({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickLinkItem(
            icon: Icons.arrow_downward_rounded,
            iconColor: _kGreen,
            label: 'Cash In',
            onTap: () => _showCashInSheet(context),
          ),
          _QuickLinkItem(
            icon: Icons.edit_document,
            iconColor: _kBrandPrimary,
            label: 'Manual\nBill',
            onTap: () => context.push('/manual-bill'),
          ),
          _QuickLinkItem(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: _kRed,
            label: 'Pending\nUdhaar',
            onTap: () => context.push('/customers'),
          ),
          _QuickLinkItem(
            icon: Icons.bar_chart_rounded,
            iconColor: Colors.orange.shade700,
            label: "Today's\nSales",
            onTap: () => _showTodaysGallaSheet(context, ref),
          ),
        ],
      ),
    );
  }

  void _showCashInSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Cash In',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Party Name (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTodaysGallaSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billsAsync = ref.read(recentBillsProvider);

    double todayTotal = 0;
    int todayCount = 0;
    final now = DateTime.now();

    billsAsync.whenData((bills) {
      for (final b in bills) {
        if (b.createdAt.year == now.year &&
            b.createdAt.month == now.month &&
            b.createdAt.day == now.day) {
          todayTotal += b.totalAmount;
          todayCount++;
        }
      }
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Today's Galla",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GallaStat(
                    label: 'Orders', value: todayCount.toString()),
                _GallaStat(
                    label: 'Total Sales',
                    value: '₹${todayTotal.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GallaStat extends StatelessWidget {
  final String label;
  final String value;
  const _GallaStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5))),
      ],
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          elevation: 0.5,
          shadowColor: Colors.black26,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dual-Tab Section
// ─────────────────────────────────────────────────────────────

class _HomeTabs extends StatelessWidget {
  const _HomeTabs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelStyle: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: theme.textTheme.labelLarge,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Recent Orders'),
              Tab(text: 'Party Summary'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _RecentBillsTab(),
                _PartySummaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1 – Recent Bills
// ─────────────────────────────────────────────────────────────

class _RecentBillsTab extends ConsumerWidget {
  const _RecentBillsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(recentBillsProvider);

    return billsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading orders: $e')),
      data: (bills) {
        if (bills.isEmpty) return const _EmptyState(message: 'No orders yet.\nTap "Snap New Order" to get started.');
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(recentBillsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.only(
                left: 12, right: 12, top: 8, bottom: 80),
            itemCount: math.min(bills.length, 20),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _BillTile(bill: bills[index]),
          ),
        );
      },
    );
  }
}

class _BillTile extends StatelessWidget {
  final dynamic bill;
  const _BillTile({required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = bill.status as String;
    final customerName = bill.customerName as String;
    final total = bill.totalAmount as double;
    final createdAt = bill.createdAt as DateTime;
    final hasImage = (bill.rawImagePath as String?) != null &&
        (bill.rawImagePath as String).isNotEmpty;

    final bool isPaid = status == 'confirmed';
    final Color statusColor = isPaid ? _kGreen : _kRed;
    final Color statusBg = isPaid ? _kGreenBg : _kRedBg;
    final String statusLabel = isPaid ? 'Paid' : 'Pending';

    final String initial = customerName.isNotEmpty
        ? customerName[0].toUpperCase()
        : '?';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _kBrandPrimary.withOpacity(0.08),
        child: Text(
          initial,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _kBrandPrimary,
            fontSize: 15,
          ),
        ),
      ),
      title: Text(
        customerName.isEmpty ? 'Unknown Customer' : customerName,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (hasImage) ...[
            Icon(
              Icons.camera_alt_outlined,
              size: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(width: 3),
          ],
          Text(
            _formatDate(createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        context.push('/order-detail', extra: bill);
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2 – Party Summary
// ─────────────────────────────────────────────────────────────

class _PartySummaryTab extends ConsumerWidget {
  const _PartySummaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(customerSummariesProvider);

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summaries) {
        if (summaries.isEmpty) return const _EmptyState(message: 'No parties yet.\nAdd an order to see your ledger.');
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(customerSummariesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.only(
                left: 12, right: 12, top: 8, bottom: 80),
            itemCount: summaries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _PartySummaryTile(summary: summaries[index]),
          ),
        );
      },
    );
  }
}

class _PartySummaryTile extends StatelessWidget {
  final dynamic summary;
  const _PartySummaryTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = summary.displayName;
    final double pending = summary.pendingAmount;
    final int billCount = summary.billCount;
    final bool isSettled = summary.isSettled;

    final Color statusColor = isSettled ? _kGreen : _kRed;
    final Color statusBg = isSettled ? _kGreenBg : _kRedBg;
    final String tagLabel = isSettled ? 'Settled' : 'Udhaar';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _kBrandPrimary.withOpacity(0.08),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _kBrandPrimary,
            fontSize: 15,
          ),
        ),
      ),
      title: Text(
        name.isEmpty ? 'Unknown' : name,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$billCount orders',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isSettled ? 'All clear' : '₹${pending.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: isSettled
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tagLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        context.push('/customers');
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Empty State
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.45),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
