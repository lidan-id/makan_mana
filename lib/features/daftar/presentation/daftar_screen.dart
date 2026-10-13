import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makan_mana/core/providers/location_providers.dart';
import 'package:makan_mana/core/providers/resto_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../detail_resto/presentation/detail_resto_screen.dart';
import '../../tambah_resto/presentation/tambah_resto_screen.dart';

class DaftarScreen extends ConsumerStatefulWidget {
  const DaftarScreen({super.key});

  @override
  ConsumerState<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends ConsumerState<DaftarScreen> {
  Map<String, String> sortOptions = {
    'terdekat': 'Mulai dari yang Terdekat',
    'terbaru': 'Terbaru Ditambahkan',
    'nama': 'A-Z Nama',
  };

  void _tampilkanFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentSort = ref.watch(sortOptionProvider);
            return SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Urutkan Berdasarkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xfff5f5f5),
                    ),

                    _buildSortOption(
                      label: sortOptions['terdekat']!,
                      isSelected: currentSort == 'terdekat',
                      onTap: () => {
                        setState(() {
                          ref.read(sortOptionProvider.notifier).state =
                              'terdekat';
                          Navigator.pop(context);
                        }),
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xfff5f5f5),
                    ),
                    _buildSortOption(
                      label: sortOptions['terbaru']!,
                      isSelected: currentSort == 'terbaru',
                      onTap: () => {
                        setState(() {
                          ref.read(sortOptionProvider.notifier).state =
                              'terbaru';
                          Navigator.pop(context);
                        }),
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xfff5f5f5),
                    ),
                    _buildSortOption(
                      label: sortOptions['nama']!,
                      isSelected: currentSort == 'nama',
                      onTap: () => {
                        setState(() {
                          ref.read(sortOptionProvider.notifier).state = 'nama';
                          Navigator.pop(context);
                        }),
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final selectedSort = ref.watch(sortOptionProvider);
    return locationAsync.when(
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
      data: (position) {
        if (position == null) {
          return Center(
            child: Text(
              'Layanan lokasi tidak tersedia. Silakan aktifkan layanan lokasi.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Makan',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Mana',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _tampilkanFilter,
                        child: const Icon(
                          Icons.sort,
                          color: AppColors.textSecondary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.textHint.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Menampilkan: ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: sortOptions[selectedSort],
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ref
                      .watch(sortedRestoListProvider)
                      .when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),

                        error: (error, stack) => Center(
                          child: Text(
                            'Terjadi kesalahan saat memuat restoran. Silakan coba lagi.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        data: (listResto) {
                          if (listResto.isEmpty) {
                            return Center(
                              child: Text(
                                'Belum ada restoran yang tersedia.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: listResto.length,
                            itemBuilder: (context, index) {
                              final resto = listResto[index];
                              final data = resto.data;

                              List<dynamic> fotoUrls = data['foto_urls'];
                              List<String> imageUrl = fotoUrls.isNotEmpty
                                  ? List<String>.from(fotoUrls)
                                  : [
                                      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=781&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                    ];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRestaurantCard(
                                  docId: resto.id,
                                  imageUrl: imageUrl,
                                  category: data['kategori'] ?? 'Kategori',
                                  name: data['nama_resto'] ?? 'Nama Restoran',
                                  distance: resto.distance,
                                  latitude: data['latitude'] ?? 0.0,
                                  longitude: data['longitude'] ?? 0.0,
                                  address:
                                      data['alamat'] ?? 'Alamat tidak tersedia',
                                  detailAddress:
                                      data['detail_alamat'] ??
                                      'Detail alamat tidak tersedia',
                                  requestedByName:
                                      data['requestedByName'] ??
                                      'Pengguna tidak ditemukan',
                                ),
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahRestoScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantCard({
    required String docId,
    required List<String> imageUrl,
    required String category,
    required String name,
    required double distance,
    required String address,
    required String detailAddress,
    required double latitude,
    required double longitude,
    required String requestedByName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRestoScreen(
              docId: docId,
              imageUrl: imageUrl,
              category: category,
              name: name,
              address: address,
              detailAddress: detailAddress,
              requestedByName: requestedByName,
              latitude: latitude,
              longitude: longitude,
              distance: distance,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    imageUrl.first,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.textHint,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${distance.toStringAsFixed(2)} km',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
