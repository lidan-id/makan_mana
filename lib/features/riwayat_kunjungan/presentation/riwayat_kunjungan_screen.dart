import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:makan_mana/core/providers/resto_provider.dart';

import '../../../core/theme/app_colors.dart';

class RiwayatKunjunganScreen extends ConsumerStatefulWidget {
  final String uid;
  const RiwayatKunjunganScreen({super.key, required this.uid});

  @override
  ConsumerState<RiwayatKunjunganScreen> createState() =>
      _RiwayatKunjunganScreenState();
}

class _RiwayatKunjunganScreenState
    extends ConsumerState<RiwayatKunjunganScreen> {
  @override
  Widget build(BuildContext context) {
    final requestRestoByUserAsync = ref.watch(requestRestoByUser(widget.uid));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Kunjungan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: requestRestoByUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (snapshot) {
          final docs = snapshot.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada riwayat kunjungan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data() as Map<String, dynamic>;
              final timestampDate = item['created_at'].toDate();
              final String imageUrl = item['foto_urls'][0] ?? '';
              final String title = item['nama_resto'] ?? 'Tanpa Nama';
              final String date = DateFormat('dd MMMM yyyy')
                  .format(timestampDate);
              final String status = item['status'] ?? '';
              final bool isApproved = status == 'approved';
              final bool isRejected = status == 'rejected';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.green.withValues(alpha: 0.12)
                            : isRejected
                            ? AppColors.error.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isApproved
                            ? 'Disetujui'
                            : isRejected
                            ? 'Ditolak'
                            : 'Menunggu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved
                              ? Colors.green
                              : isRejected
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
