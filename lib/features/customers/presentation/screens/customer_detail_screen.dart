// lib/features/customers/presentation/screens/customer_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../billing/presentation/providers/bill_provider.dart';
import '../../../billing/presentation/providers/shop_profile_provider.dart';
import '../../data/models/customer_summary.dart';
import '../providers/customer_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String? phone;
  final String displayName;

  const CustomerDetailScreen({
    super.key,
    required this.phone,
    required this.displayName,
  });

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  late final CustomerDetailArgs _args;

  @override
  void initState() {
    super.initState();
    _args = CustomerDetailArgs(
      phone: widget.phone,
      displayName: widget.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(customerDetailProvider(_args));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          // Compute balances from entries
          double totalBilled = 0;
          double totalPaid = 0;
          for (final e in entries) {
            if (e.type == LedgerEntryType.bill) {
              totalBilled += e.amount;
            } else {
              totalPaid += e.amount;
            }
          }
          final pending = totalBilled - totalPaid;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                elevation: 0,
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete_customer') {
                        _confirmDeleteCustomer(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete_customer',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Customer',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE8650A), Color(0xFFFF9D4D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            // Avatar + name
                            Row(
                              children: [
                                _Avatar(name: widget.displayName, size: 48),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (widget.phone != null)
                                        Text(
                                          widget.phone!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Balance Summary ───────────────────────────
              SliverToBoxAdapter(
                child: _BalanceSummaryCard(
                  totalBilled: totalBilled,
                  totalPaid: totalPaid,
                  pending: pending,
                ),
              ),

              // ── Action Buttons ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.send_rounded,
                          label: 'Send Reminder',
                          color: const Color(0xFF25D366),
                          onTap: () => _sendReminder(context, pending),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Record Payment',
                          color: const Color(0xFF0066FF),
                          onTap: () => _showAddPaymentSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Timeline Header ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
              ),

              // ── Timeline ──────────────────────────────────
              entries.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _LedgerEntryTile(entry: entries[i]),
                          childCount: entries.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _sendReminder(BuildContext context, double pending) async {
    if (pending <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This customer has no pending balance!')),
      );
      return;
    }

    String? phone = widget.phone;
    final name = widget.displayName;

    // Use a professional message template
    final shopProfileAsync = ref.read(shopProfileProvider);
    final shopName = shopProfileAsync.valueOrNull?.shopName ?? '';
    final shopPrefix = shopName.isNotEmpty ? ' from $shopName' : '';

    final message =
        'Dear $name, this is a friendly reminder$shopPrefix regarding your pending balance of ₹${pending.toStringAsFixed(0)}. '
        'Please pay at your earliest convenience. Thank you! 🙏';

    // If phone is null, attempt to look it up from history
    if (phone == null || phone.isEmpty) {
      final db = ref.read(appDatabaseProvider);
      phone = await db.getPhoneByName(name);
    }

    if (phone == null || phone.isEmpty) {
      if (!context.mounted) return;
      _showNoPhoneDialog(context, message);
      return;
    }

    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    // WhatsApp URL format: ensure no leading 0 and add country code if missing
    String target = cleaned;
    if (!target.startsWith('+') && target.length == 10) {
      target = '91$target';
    } else if (target.startsWith('+')) {
      target = target.substring(1);
    }

    final waUrl = 'https://wa.me/$target?text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(waUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Try fallback scheme
        final whatsappUri = Uri.parse(
            'whatsapp://send?phone=$target&text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          throw 'WhatsApp not installable/launchable';
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: message));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('WhatsApp not available. Message copied to clipboard!'),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _showNoPhoneDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This customer has no phone number. Message has been copied to clipboard.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message,
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard!')),
              );
            },
            child: const Text('Copy & Close'),
          ),
        ],
      ),
    );
    Clipboard.setData(ClipboardData(text: message));
  }

  void _showAddPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPaymentSheet(
        phone: widget.phone,
        customerName: widget.displayName,
        onSaved: () {
          // Invalidate so the detail refreshes
          ref.invalidate(customerDetailProvider(_args));
          ref.invalidate(customerSummariesProvider);
        },
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Text(
            'This will permanently delete ${widget.displayName} and all their transaction history (bills and payments). This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await ref.read(customerRepositoryProvider).deleteCustomer(
                    widget.phone,
                    widget.displayName,
                  );
              if (context.mounted) {
                ref.invalidate(customerSummariesProvider);
                context.pop(); // Go back to customer list
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ── Balance Summary Card ─────────────────────────────────────────────────

class _BalanceSummaryCard extends StatelessWidget {
  final double totalBilled;
  final double totalPaid;
  final double pending;

  const _BalanceSummaryCard({
    required this.totalBilled,
    required this.totalPaid,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = pending > 0;
    final pendingColor =
        isPending ? const Color(0xFFBF2600) : const Color(0xFF00875A);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryCell(
            label: 'Total Billed',
            value: '₹${totalBilled.toStringAsFixed(0)}',
            color: theme.colorScheme.onSurface,
          ),
          _Divider(),
          _SummaryCell(
            label: 'Total Paid',
            value: '₹${totalPaid.toStringAsFixed(0)}',
            color: const Color(0xFF00875A),
          ),
          _Divider(),
          _SummaryCell(
            label: pending < 0 ? 'Overpaid' : 'Pending',
            value: '₹${pending.abs().toStringAsFixed(0)}',
            color: pendingColor,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
    );
  }
}

// ── Action Button ────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ledger Entry Tile ────────────────────────────────────────────────────

class _LedgerEntryTile extends ConsumerWidget {
  final LedgerEntry entry;
  const _LedgerEntryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBill = entry.type == LedgerEntryType.bill;
    final color = isBill ? const Color(0xFFBF2600) : const Color(0xFF00875A);
    final icon = isBill ? Icons.receipt_long_rounded : Icons.payments_outlined;
    final amountPrefix = isBill ? '' : '+ ';

    Widget tile = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          isBill ? 'Bill' : 'Payment',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(entry.date),
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12),
            ),
            if (!isBill && entry.paymentNote != null)
              Text(
                entry.paymentNote!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amountPrefix₹${entry.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (isBill) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ],
          ],
        ),
      ),
    );

    // Bill entries are tappable — show scanned image full-screen if available
    if (isBill && entry.imagePath != null && entry.imagePath!.isNotEmpty) {
      tile = InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showBillImage(context, entry.imagePath!),
        onLongPress: () => _confirmDeleteEntry(context, ref),
        child: tile,
      );
    } else {
      tile = InkWell(
        borderRadius: BorderRadius.circular(14),
        onLongPress: () => _confirmDeleteEntry(context, ref),
        child: tile,
      );
    }

    return tile;
  }

  void _confirmDeleteEntry(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.type == LedgerEntryType.bill
            ? 'Delete Bill?'
            : 'Delete Payment?'),
        content: const Text('This entry will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (entry.type == LedgerEntryType.bill && entry.billId != null) {
                await ref
                    .read(billRepositoryProvider)
                    .deleteBill(entry.billId!);
              } else if (entry.type == LedgerEntryType.payment &&
                  entry.paymentId != null) {
                await ref
                    .read(customerRepositoryProvider)
                    .deletePayment(entry.paymentId!);
              }

              if (!context.mounted) return;

              // Refresh UI
              final phone =
                  (context.findAncestorStateOfType<_CustomerDetailScreenState>()
                          as dynamic)
                      ?._args
                      .phone;
              final name =
                  (context.findAncestorStateOfType<_CustomerDetailScreenState>()
                          as dynamic)
                      ?._args
                      .displayName;

              if (phone != null || name != null) {
                ref.invalidate(customerDetailProvider(
                    CustomerDetailArgs(phone: phone, displayName: name)));
                ref.invalidate(customerSummariesProvider);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBillImage(BuildContext context, String imagePath) {
    final file = File(imagePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill image not found on device')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
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

// ── Add Payment Bottom Sheet ─────────────────────────────────────────────

class _AddPaymentSheet extends ConsumerStatefulWidget {
  final String? phone;
  final String customerName;
  final VoidCallback onSaved;

  const _AddPaymentSheet({
    required this.phone,
    required this.customerName,
    required this.onSaved,
  });

  @override
  ConsumerState<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<_AddPaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(addPaymentProvider);

    // Auto-close on success
    ref.listen(addPaymentProvider, (_, next) {
      if (next.success) {
        widget.onSaved();
        Navigator.pop(context);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded,
                  color: Color(0xFF0066FF)),
              const SizedBox(width: 10),
              Text(
                'Record Payment',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'from ${widget.customerName}',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Amount
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Amount received (₹)',
              prefixText: '₹ ',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // Note
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. Cash, UPI, Part payment',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // Date picker
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Date: ${_date.day}/${_date.month}/${_date.year}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: state.loading
                  ? null
                  : () {
                      final amount = double.tryParse(_amountCtrl.text.trim());
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid amount')),
                        );
                        return;
                      }
                      ref.read(addPaymentProvider.notifier).addPayment(
                            phone: widget.phone,
                            customerName: widget.customerName,
                            amount: amount,
                            note: _noteCtrl.text.trim().isEmpty
                                ? null
                                : _noteCtrl.text.trim(),
                            paidAt: _date,
                          );
                    },
              child: state.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save Payment',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
