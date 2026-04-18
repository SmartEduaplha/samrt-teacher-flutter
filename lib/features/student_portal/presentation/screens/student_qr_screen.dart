import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class StudentQrScreen extends ConsumerWidget {
  const StudentQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.studentQrCode),
      ),
      body: Center(
        child: student == null
            ? Text(
                context.l10n.notLoggedIn,
                style: TextStyle(color: colorScheme.onSurface.withAlpha(160)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Student Info ──
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withAlpha(25),
                      child: Icon(
                        Icons.person_rounded,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (student.groupName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        student.groupName,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── QR Code Card ──
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: student.id,
                                version: QrVersions.auto,
                                size: 220,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF4F46E5),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF1F2937),
                                ),

                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.l10n.showQrHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Hint ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16,
                            color: colorScheme.onSurface.withAlpha(120)),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.screenshotHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
