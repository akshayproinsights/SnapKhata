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
import '../../../customers/data/models/customer_summary.dart';

const _kGreen = Color(0xFF1B8A2A);
const _kGreenBg = Color(0xFFE8F5E9);
const _kRed = Color(0xFFC62828);
const _kRedBg = Color(0xFFFFEBEE);
const _kBrandPrimary = Color(0xFF3949AB);

// ─────────────────────────────────────────────────────────────
// Selection Providers
// ─────────────────────────────────────────────────────────────

final selectedBillsProvider = StateProvider<Set<int>>((ref) => {});

class SelectionKey {
  final String? phone;
  final String name;
  SelectionKey(this.phone, this.name);
  @override
  bool operator ==(Object other) =>
      other is SelectionKey && other.phone == phone && other.name == name;
  @override
  int get hashCode => Object.hash(phone, name);
  String get identifier => '${phone ?? "none"}_$name';
}

final selectedPartiesProvider = StateProvider<Set<String>>((ref) => {});

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

    final displayName = shopName.isNotEmpty ? shopName : 'My Shop';

    final selectedBills = ref.watch(selectedBillsProvider);
    final selectedParties = ref.watch(selectedPartiesProvider);
    final bool isSelectingBills = selectedBills.isNotEmpty;
    final bool isSelectingParties = selectedParties.isNotEmpty;
    final bool isSelectionMode = isSelectingBills || isSelectingParties;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedBillsProvider.notifier).state = {};
                  ref.read(selectedPartiesProvider.notifier).state = {};
                },
              )
            : null,
        title: isSelectionMode
            ? Text(
                '${isSelectingBills ? selectedBills.length : selectedParties.length} selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              )
            : GestureDetector(
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
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: _kRed),
              tooltip: 'Delete Selected',
              onPressed: () => _confirmDelete(context, ref),
            )
          else ...[
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final selectedBills = ref.read(selectedBillsProvider);
    final selectedParties = ref.read(selectedPartiesProvider);

    final String title = selectedBills.isNotEmpty
        ? 'Delete ${selectedBills.length} order(s)?'
        : 'Delete ${selectedParties.length} party(s)?';
    final String content = selectedBills.isNotEmpty
        ? 'This will permanently remove these orders from your history.'
        : 'This will delete these customers and ALL their associated orders and payments.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleDeletion(ref);
            },
            style: FilledButton.styleFrom(backgroundColor: _kRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeletion(WidgetRef ref) async {
    final selectedBills = ref.read(selectedBillsProvider);
    final selectedParties = ref.read(selectedPartiesProvider);

    if (selectedBills.isNotEmpty) {
      await ref
          .read(billRepositoryProvider)
          .deleteBills(selectedBills.toList());
      ref.read(selectedBillsProvider.notifier).state = {};
    } else if (selectedParties.isNotEmpty) {
      final List<({String? phone, String name})> parties =
          selectedParties.map((id) {
        // Split back the identifier: phone_name
        final idx = id.indexOf('_');
        final phone = id.substring(0, idx);
        final name = id.substring(idx + 1);
        return (phone: phone == 'none' ? null : phone, name: name);
      }).toList();

      await ref.read(customerRepositoryProvider).deleteCustomers(parties);
      ref.read(selectedPartiesProvider.notifier).state = {};
    }
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
            label: 'Manual\nOrder',
            onTap: () => context.push('/manual-bill'),
          ),
          _QuickLinkItem(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: _kRed,
            label: 'Pending\nUdhaar',
            onTap: () =>
                context.push('/customers', extra: {'showPendingOnly': true}),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => const _CashInSheet(),
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
                _GallaStat(label: 'Orders', value: todayCount.toString()),
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
        if (bills.isEmpty)
          return const _EmptyState(
              message: 'No orders yet.\nTap "Snap New Order" to get started.');
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(recentBillsProvider),
          child: ListView.separated(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 80),
            itemCount: math.min(bills.length, 20),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _BillTile(index: index, bill: bills[index]),
          ),
        );
      },
    );
  }
}

class _BillTile extends ConsumerWidget {
  final int index;
  final dynamic bill;
  const _BillTile({required this.index, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final int billId = bill.id as int;
    final selectedBills = ref.watch(selectedBillsProvider);
    final isSelected = selectedBills.contains(billId);
    final bool isSelectionMode = selectedBills.isNotEmpty;

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

    final String initial =
        customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';

    return Container(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
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
            if (isSelected)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          customerName.isEmpty ? 'Unknown Customer' : customerName,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
          if (isSelectionMode) {
            _toggleSelection(ref, billId);
          } else {
            context.push('/order-detail', extra: bill);
          }
        },
        onLongPress: () {
          _toggleSelection(ref, billId);
        },
      ),
    );
  }

  void _toggleSelection(WidgetRef ref, int id) {
    final current = ref.read(selectedBillsProvider);
    if (current.contains(id)) {
      ref.read(selectedBillsProvider.notifier).state =
          current.where((e) => e != id).toSet();
    } else {
      ref.read(selectedBillsProvider.notifier).state = {...current, id};
      // Clear party selection if any
      ref.read(selectedPartiesProvider.notifier).state = {};
    }
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
        if (summaries.isEmpty)
          return const _EmptyState(
              message: 'No parties yet.\nAdd an order to see your ledger.');
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(customerSummariesProvider),
          child: ListView.separated(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 80),
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

class _PartySummaryTile extends ConsumerWidget {
  final dynamic summary;
  const _PartySummaryTile({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final String name = summary.displayName;
    final String? phone = summary.phone;
    final double pending = summary.pendingAmount;
    final int billCount = summary.billCount;
    final bool isSettled = summary.isSettled;

    final partyId = SelectionKey(phone, name).identifier;
    final selectedParties = ref.watch(selectedPartiesProvider);
    final isSelected = selectedParties.contains(partyId);
    final bool isSelectionMode = selectedParties.isNotEmpty;

    final Color statusColor = isSettled ? _kGreen : _kRed;
    final Color statusBg = isSettled ? _kGreenBg : _kRedBg;
    final String tagLabel = isSettled ? 'Settled' : 'Udhaar';

    return Container(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
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
            if (isSelected)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          name.isEmpty ? 'Unknown' : name,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
          if (isSelectionMode) {
            _toggleSelection(ref, partyId);
          } else {
            context.push('/customer-detail', extra: {
              'phone': phone,
              'displayName': name,
            });
          }
        },
        onLongPress: () {
          _toggleSelection(ref, partyId);
        },
      ),
    );
  }

  void _toggleSelection(WidgetRef ref, String id) {
    final current = ref.read(selectedPartiesProvider);
    if (current.contains(id)) {
      ref.read(selectedPartiesProvider.notifier).state =
          current.where((e) => e != id).toSet();
    } else {
      ref.read(selectedPartiesProvider.notifier).state = {...current, id};
      // Clear bill selection if any
      ref.read(selectedBillsProvider.notifier).state = {};
    }
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
                size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
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

// ─────────────────────────────────────────────────────────────
// Cash In Sheet (Autocomplete)
// ─────────────────────────────────────────────────────────────

class _CashInSheet extends ConsumerStatefulWidget {
  const _CashInSheet();

  @override
  ConsumerState<_CashInSheet> createState() => _CashInSheetState();
}

class _CashInSheetState extends ConsumerState<_CashInSheet> {
  final _amountController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _partyFocusNode = FocusNode();

  String? _selectedPhone;
  bool _isSaving = false;
  List<CustomerSummary> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _partyNameController.addListener(_updateSuggestions);
    _partyFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _partyNameController.dispose();
    _partyFocusNode.dispose();
    super.dispose();
  }

  void _updateSuggestions() {
    if (!mounted) return;
    final summariesAsync = ref.read(customerSummariesProvider);
    if (!summariesAsync.hasValue) return;

    final query = _partyNameController.text.trim().toLowerCase();

    if (query.isEmpty) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    // Reset selected phone as user types new things
    _selectedPhone = null;

    final summaries = summariesAsync.value!;
    final matches = summaries
        .where((s) => s.displayName.toLowerCase().contains(query))
        .toList();

    final exactMatch = matches.any((s) => s.displayName.toLowerCase() == query);
    if (!exactMatch && query.isNotEmpty) {
      matches.add(CustomerSummary(
        displayName: query, // Special indicator
        phone: null,
        totalBilled: 0,
        totalPaid: 0,
        pendingAmount: -1, // Use -1 as a flag for "new"
        lastActivity: DateTime.now(),
        billCount: 0,
      ));
    }

    setState(() {
      _suggestions = matches;
    });
  }

  void _selectSuggestion(CustomerSummary option) {
    if (option.pendingAmount == -1) {
      _partyNameController.text = option.displayName;
      _selectedPhone = null;
    } else {
      _partyNameController.text = option.displayName;
      _selectedPhone = option.phone;
    }
    setState(() {
      _suggestions = [];
    });
    _partyFocusNode.unfocus();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final name = _partyNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a party name')),
      );
      return;
    }

    final summariesAsync = ref.read(customerSummariesProvider);
    String? finalPhone = _selectedPhone;
    String finalName = name;

    if (summariesAsync.hasValue) {
      final summaries = summariesAsync.value!;
      final exactMatch = summaries
          .where((s) => s.displayName.toLowerCase() == name.toLowerCase())
          .firstOrNull;
      if (exactMatch != null) {
        finalPhone = exactMatch.phone;
        finalName = exactMatch.displayName;
      } else {
        finalPhone = null;
        finalName = name;
      }
    }

    setState(() => _isSaving = true);

    await ref.read(addPaymentProvider.notifier).addPayment(
          phone: finalPhone,
          customerName: finalName,
          amount: amount,
          note: 'Cash In',
        );

    if (!mounted) return;

    final paymentState = ref.read(addPaymentProvider);
    if (paymentState.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('₹${amount.toStringAsFixed(0)} received from $finalName'),
          backgroundColor: const Color(0xFF1B8A2A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (paymentState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${paymentState.error}'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      // Premium bottom sheet feel: tall enough to fit suggestions, grows with keyboard
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.75,
        maxHeight: screenHeight * 0.92,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomPadding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B8A2A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download_rounded,
                      size: 18, color: Color(0xFF1B8A2A)),
                  const SizedBox(width: 6),
                  Text(
                    'Quick Cash In',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF1B8A2A),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Field
                  Text(
                    'Amount Received',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Color(0xFF1B8A2A),
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: '₹ 0',
                      hintStyle: TextStyle(
                        color: const Color(0xFF1B8A2A).withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Party Name Input
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _partyFocusNode.hasFocus
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _partyNameController,
                      focusNode: _partyFocusNode,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Who is paying?',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: _partyFocusNode.hasFocus
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        suffixIcon: _partyNameController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _partyNameController.clear();
                                  setState(() => _selectedPhone = null);
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),

                  // Inline Suggestions
                  if (_suggestions.isNotEmpty && _partyFocusNode.hasFocus) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 64, endIndent: 16),
                        itemBuilder: (context, index) {
                          final option = _suggestions[index];
                          final isNew = option.pendingAmount == -1;

                          if (isNew) {
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_add_rounded,
                                    size: 18, color: theme.colorScheme.primary),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    'Add ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      option.displayName,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              onTap: () => _selectSuggestion(option),
                            );
                          }

                          final initial = option.displayName.isNotEmpty
                              ? option.displayName[0].toUpperCase()
                              : '?';

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  const Color(0xFF3949AB).withOpacity(0.1),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3949AB),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              option.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: option.phone != null
                                ? Text(option.phone!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ))
                                : null,
                            trailing: Text(
                              option.pendingAmount > 0
                                  ? 'Pend: ₹${option.pendingAmount.toStringAsFixed(0)}'
                                  : '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFC62828),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            onTap: () => _selectSuggestion(option),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Fixed Save Button at the Bottom
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56, // Slightly taller for premium feel
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.check_circle_rounded, size: 24),
              label: Text(
                _isSaving ? 'Processing...' : 'Save Cash In',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B8A2A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
