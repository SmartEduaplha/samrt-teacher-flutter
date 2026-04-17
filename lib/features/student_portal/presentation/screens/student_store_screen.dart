import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../store/data/models/store_item_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class StudentStoreScreen extends ConsumerWidget {
  const StudentStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeProvider);
    final teacherProfileAsync = ref.watch(teacherProfileProvider);
    final currentStudent = ref.watch(currentStudentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notebooksStore, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: storeAsync.when(
        data: (items) {
          final activeItems = items.where((item) => item.isActive).toList();
          
          if (activeItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: activeItems.length,
            itemBuilder: (context, index) {
              final item = activeItems[index];
              return _ProductCard(
                item: item,
                teacherPhone: teacherProfileAsync.value?.phone ?? '',
                studentName: currentStudent?.fullName ?? context.l10n.student,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${context.l10n.errorOccurred}: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: colorScheme.primary.withAlpha(50)),
            const SizedBox(height: 24),
            Text(
              context.l10n.storeIsEmpty,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noItemsAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StoreItemModel item;
  final String teacherPhone;
  final String studentName;

  const _ProductCard({
    required this.item,
    required this.teacherPhone,
    required this.studentName,
  });

  Future<void> _orderViaWhatsApp(BuildContext context) async {
    if (teacherPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.teacherPhoneUnavailable)),
      );
      return;
    }

    final message = context.l10n.whatsappStoreOrderMessage(
      item.title,
      item.category,
      item.price,
      studentName,
    );
    final cleanPhone = teacherPhone.replaceAll(RegExp(r'\D'), '');
    // Ensure international format if needed, but for local Egyptian numbers usually start with 01
    final phoneWithCountry = cleanPhone.startsWith('0') ? '2$cleanPhone' : cleanPhone;
    
    final url = Uri.parse('https://wa.me/$phoneWithCountry?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.whatsappOpenError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withAlpha(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _PlaceholderImage(),
                  )
                else
                  _PlaceholderImage(),
                
                // Category Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price} ${context.l10n.currencyEgp}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: () => _orderViaWhatsApp(context),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(context.l10n.orderNow, style: const TextStyle(fontSize: 11)),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book_rounded, size: 40, color: colorScheme.primary.withAlpha(50)),
    );
  }
}
