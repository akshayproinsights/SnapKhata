// lib/features/customers/presentation/screens/customers_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/customer_summary.dart';
import '../providers/customer_provider.dart';

// ── Brand colours ────────────────────────────────────────────────────────
const _kOrange = Color(0xFFE8650A);
const _kOrangeLight = Color(0xFFFF9D4D);
const _kGreen = Color(0xFF00875A);
const _kGreenBg = Color(0xFFE6F4ED);
const _kRed = Color(0xFFBF2600);
const _kRedBg = Color(0xFFFFF0E6);
const _kBlue = Color(0xFF0066FF);
const _kBlueBg = Color(0xFFE6F0FF);

enum _Filter { all, pending, settled, overpaid }

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _search = '';
  _Filter _filter = _Filter.all;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<CustomerSummary> _applyFilters(List<CustomerSummary> list) {
    var result = list;

    // Text search
    if (_search.isNotEmpty) {
      final s = _search.toLowerCase();
      result = result
          .where((c) =>
              c.displayName.toLowerCase().contains(s) ||
              (c.phone?.contains(s) ?? false))
          .toList();
    }

    // Tab filter
    switch (_filter) {
      case _Filter.pending:
        result = result.where((c) => c.pendingAmount > 0).toList();
        break;
      case _Filter.settled:
        result = result.where((c) => c.pendingAmount == 0).toList();
        break;
      case _Filter.overpaid:
        result = result.where((c) => c.pendingAmount < 0).toList();
        break;
      case _Filter.all:
        break;
    }

    // Sort: pending first, then by latest activity
    result.sort((a, b) {
      if (a.pendingAmount > 0 && b.pendingAmount <= 0) return -1;
      if (b.pendingAmount > 0 && a.pendingAmount <= 0) return 1;
      return b.lastActivity.compareTo(a.lastActivity);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summariesAsync = ref.watch(customerSummariesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            _Header(
              summariesAsync: summariesAsync,
              onBack: () => context.pop(),
            ),

            // ── Search Bar ─────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v.trim()),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    suffixIcon: _search.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                            child: Icon(Icons.close_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4)),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // ── Summary Cards ──────────────────────────────────
            summariesAsync.when(
              data: (list) => _SummaryRow(summaries: list),
              loading: () => const SizedBox(height: 8),
              error: (_, __) => const SizedBox(height: 8),
            ),

            // ── Filter Tabs ────────────────────────────────────
            _FilterTabs(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
              summariesAsync: summariesAsync,
            ),

            // ── Customer List ──────────────────────────────────
            Expanded(
              child: summariesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _kOrange),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: _kRed),
                        const SizedBox(height: 12),
                        Text('Something went wrong',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text('$e',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                data: (allSummaries) {
                  final filtered = _applyFilters(allSummaries);

                  if (filtered.isEmpty) {
                    return _EmptyCustomers(
                      hasSearch: _search.isNotEmpty,
                      filter: _filter,
                    );
                  }

                  return RefreshIndicator(
                    color: _kOrange,
                    onRefresh: () async =>
                        ref.refresh(customerSummariesProvider),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _CustomerCard(
                        summary: filtered[i],
                        onTap: () => context.push(
                          '/customer-detail',
                          extra: {
                            'phone': filtered[i].phone,
                            'displayName': filtered[i].displayName,
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AsyncValue<List<CustomerSummary>> summariesAsync;
  final VoidCallback onBack;

  const _Header({required this.summariesAsync, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
                splashRadius: 22,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    summariesAsync.when(
                      data: (list) {
                        final totalPending = list.fold<double>(
                            0, (s, c) => s + math.max(0, c.pendingAmount));
                        return Text(
                          '${list.length} customers · ₹${_formatAmount(totalPending)} pending',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary Row (You'll Get / You'll Give) ───────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<CustomerSummary> summaries;
  const _SummaryRow({required this.summaries});

  @override
  Widget build(BuildContext context) {
    double youllGet = 0;
    double youllGive = 0;
    for (final c in summaries) {
      if (c.pendingAmount > 0) {
        youllGet += c.pendingAmount;
      } else if (c.pendingAmount < 0) {
        youllGive += c.pendingAmount.abs();
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: "You'll Get",
              amount: youllGet,
              color: _kRed,
              bgColor: _kRedBg,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              label: "You'll Give",
              amount: youllGive,
              color: _kGreen,
              bgColor: _kGreenBg,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${_formatAmount(amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Tabs ──────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final _Filter selected;
  final ValueChanged<_Filter> onChanged;
  final AsyncValue<List<CustomerSummary>> summariesAsync;

  const _FilterTabs({
    required this.selected,
    required this.onChanged,
    required this.summariesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final counts = summariesAsync.when(
      data: (list) {
        return {
          _Filter.all: list.length,
          _Filter.pending: list.where((c) => c.pendingAmount > 0).length,
          _Filter.settled: list.where((c) => c.pendingAmount == 0).length,
          _Filter.overpaid: list.where((c) => c.pendingAmount < 0).length,
        };
      },
      loading: () => <_Filter, int>{},
      error: (_, __) => <_Filter, int>{},
    );

    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All',
            count: counts[_Filter.all],
            isSelected: selected == _Filter.all,
            onTap: () => onChanged(_Filter.all),
            color: _kOrange,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            count: counts[_Filter.pending],
            isSelected: selected == _Filter.pending,
            onTap: () => onChanged(_Filter.pending),
            color: _kRed,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Settled',
            count: counts[_Filter.settled],
            isSelected: selected == _Filter.settled,
            onTap: () => onChanged(_Filter.settled),
            color: _kGreen,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Overpaid',
            count: counts[_Filter.overpaid],
            isSelected: selected == _Filter.overpaid,
            onTap: () => onChanged(_Filter.overpaid),
            color: _kBlue,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Customer Card ────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final CustomerSummary summary;
  final VoidCallback onTap;

  const _CustomerCard({required this.summary, required this.onTap});

  static const _avatarColors = [
    Color(0xFFE8650A),
    Color(0xFF7B2FFF),
    Color(0xFF0066FF),
    Color(0xFF00875A),
    Color(0xFFBF2600),
    Color(0xFF0747A6),
    Color(0xFF6554C0),
    Color(0xFF00A3BF),
  ];

  Color _avatarColor(String name) {
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % _avatarColors.length : 0;
    return _avatarColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = summary.pendingAmount;
    final isPending = pending > 0;
    final isOverpaid = pending < 0;

    final Color amountColor;
    final Color statusBg;
    final String statusLabel;

    if (isPending) {
      amountColor = _kRed;
      statusBg = _kRedBg;
      statusLabel = 'Pending';
    } else if (isOverpaid) {
      amountColor = _kBlue;
      statusBg = _kBlueBg;
      statusLabel = 'Overpaid';
    } else {
      amountColor = _kGreen;
      statusBg = _kGreenBg;
      statusLabel = 'Settled';
    }

    final avatarColor = _avatarColor(summary.displayName);
    final initial = summary.displayName.isNotEmpty
        ? summary.displayName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // ── Avatar ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: avatarColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Name + meta ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.displayName.isEmpty
                            ? 'Unknown'
                            : summary.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (summary.phone != null &&
                              summary.phone!.isNotEmpty) ...[
                            Icon(Icons.call_outlined,
                                size: 11,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.35)),
                            const SizedBox(width: 3),
                            Text(
                              summary.phone!,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.45),
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${summary.billCount} bill${summary.billCount != 1 ? "s" : ""}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Amount + status ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatAmount(pending.abs())}',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────

class _EmptyCustomers extends StatelessWidget {
  final bool hasSearch;
  final _Filter filter;
  const _EmptyCustomers({required this.hasSearch, required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String subtitle;
    IconData icon;

    if (hasSearch) {
      title = 'No customers found';
      subtitle = 'Try a different name or phone number';
      icon = Icons.search_off_rounded;
    } else if (filter == _Filter.pending) {
      title = 'No pending payments';
      subtitle = 'All your customers are settled!';
      icon = Icons.check_circle_outline_rounded;
    } else if (filter == _Filter.settled) {
      title = 'No settled customers';
      subtitle = 'Customers with zero balance will appear here';
      icon = Icons.account_balance_wallet_outlined;
    } else if (filter == _Filter.overpaid) {
      title = 'No overpaid customers';
      subtitle = 'Customers who paid extra will appear here';
      icon = Icons.savings_outlined;
    } else {
      title = 'No customers yet';
      subtitle = 'Scan bills with customer details\nto see them here';
      icon = Icons.people_outline_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kOrange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: _kOrange),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

String _formatAmount(double amount) {
  if (amount >= 10000000) {
    return '${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount >= 100000) {
    return '${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}
