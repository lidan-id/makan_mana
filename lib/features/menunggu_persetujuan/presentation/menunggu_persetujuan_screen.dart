import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makan_mana/core/controllers/resto_controller.dart';
import 'package:makan_mana/core/providers/resto_provider.dart';
import 'package:makan_mana/features/detail_resto/presentation/detail_resto_screen.dart';

import '../../../core/theme/app_colors.dart';

class MenungguPersetujuanScreen extends ConsumerStatefulWidget {
  const MenungguPersetujuanScreen({super.key});

  @override
  ConsumerState<MenungguPersetujuanScreen> createState() =>
      _MenungguPersetujuanScreenState();
}

class _MenungguPersetujuanScreenState
    extends ConsumerState<MenungguPersetujuanScreen> {
  @override
  initState() {
    super.initState();
  }

  Future<void> _handleRejectEditRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) async {
    try {
      await ref
          .read(restoControllerProvider)
          .deleteResto(requestId, 'resto_edit');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil ditolak'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleApproveEditRequest(
    BuildContext context,
    WidgetRef ref,
    RestoModel resto,
  ) async {
    final Map<String, dynamic> editData = resto.data;
    try {
      await ref
          .read(restoControllerProvider)
          .approveEditResto(resto.id, editData);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleRejectRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) async {
    try {
      await ref
          .read(restoControllerProvider)
          .deleteResto(requestId, 'request_resto');
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleApproveRequest(
    BuildContext context,
    WidgetRef ref,
    RestoModel resto,
  ) async {
    try {
      await ref
          .read(restoControllerProvider)
          .approveResto(resto.id, resto.type!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPendingAsync = ref.watch(totalPendingListProvider);

    return totalPendingAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Terjadi kesalahan saat mendapatkan lokasi. Silakan coba lagi.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
      data: (docs) {
        final totalPendingCount = docs.length;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.cardColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menunggu Persetujuan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$totalPendingCount request menunggu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalPendingCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: totalPendingCount,
            itemBuilder: (context, index) {
              final item = docs[index].data;
              final bool isEdit = docs[index].type == 'resto_edit';
              final title = item['nama_resto'] ?? 'Tanpa Nama';
              final category = item['kategori'] ?? 'Tanpa Kategori';
              final address = item['alamat'] ?? 'Tanpa Alamat';
              final detailAddress = item['detail_alamat'] ?? 'Tidak Diketahui';
              final latitude = item['latitude'] ?? 0.0;
              final longitude = item['longitude'] ?? 0.0;
              final sender = item['requestedByName'] ?? 'Tidak Diketahui';
              final imageUrl = item['foto_urls'][0];
              final distance = docs[index].distance;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRestoScreen(
                        docId: docs[index].id,
                        imageUrl: item['foto_urls'].cast<String>(),
                        category: category,
                        name: title,
                        address: address,
                        detailAddress: detailAddress,
                        requestedByName: sender,
                        latitude: latitude,
                        longitude: longitude,
                        distance: distance,
                        isEditable: false,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isEdit ? Colors.orange : Colors.blue,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    isEdit ? 'EDIT' : 'BARU',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Dikirim oleh: ',
                                          ),
                                          TextSpan(
                                            text: sender,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => {
                                if (isEdit)
                                  _handleRejectEditRequest(
                                    context,
                                    ref,
                                    docs[index].id,
                                  )
                                else
                                  _handleRejectRequest(
                                    context,
                                    ref,
                                    docs[index].id,
                                  ),
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Tolak',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => {
                                if (isEdit)
                                  _handleApproveEditRequest(
                                    context,
                                    ref,
                                    docs[index],
                                  )
                                else
                                  _handleApproveRequest(
                                    context,
                                    ref,
                                    docs[index],
                                  ),
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Setujui',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
