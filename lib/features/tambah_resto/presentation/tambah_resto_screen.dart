import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makan_mana/core/controllers/foto_resto_controller.dart';
import 'package:makan_mana/core/controllers/resto_controller.dart';
import 'package:makan_mana/core/providers/location_providers.dart';
import 'package:makan_mana/core/utils/open_on_google_maps.dart';
import 'package:makan_mana/features/tambah_resto/presentation/map_picker_screen.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../shared/photo/open_full_photo.dart';

class TambahRestoScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? docId;
  final String? initialName;
  final String? initialCategory;
  final String? initialAddress;
  final String? initialDetailAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final List<String>? initialImageUrls;
  const TambahRestoScreen({
    super.key,
    this.isEdit = false,
    this.docId,
    this.initialName,
    this.initialCategory,
    this.initialAddress,
    this.initialDetailAddress,
    this.initialLatitude,
    this.initialLongitude,
    this.initialImageUrls,
  });

  @override
  ConsumerState<TambahRestoScreen> createState() => _TambahRestoState();
}

class _TambahRestoState extends ConsumerState<TambahRestoScreen> {
  TextEditingController namaRestoController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController detailAlamatController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  double? _latitude;
  double? _longitude;

  @override
  initState() {
    super.initState();
    if (widget.isEdit) {
      namaRestoController.text = widget.initialName ?? '';
      kategoriController.text = widget.initialCategory ?? '';
      alamatController.text = widget.initialAddress ?? '';
      detailAlamatController.text = widget.initialDetailAddress ?? '';
      _latitude = widget.initialLatitude;
      _longitude = widget.initialLongitude;
      Future.microtask(
        () => ref
            .read(fotoMenuProvider.notifier)
            .initFotos(widget.initialImageUrls),
      );
    }
  }

  @override
  void dispose() {
    namaRestoController.dispose();
    kategoriController.dispose();
    alamatController.dispose();
    detailAlamatController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await ref.refresh(locationProvider.future);
      if (position == null) throw 'Izin lokasi ditolak atau GPS mati.';

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapPickerScreen()),
      );

      if (result != null && result is PickedData) {
        setState(() {
          alamatController.text = result.addressName;
          _latitude = result.latLong.latitude;
          _longitude = result.latLong.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _tampilkanMenuFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    final errorMessage = await ref
                        .read(fotoMenuProvider.notifier)
                        .pickFoto(ImageSource.gallery);

                    if (errorMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ambil dari Kamera'),

                  onTap: () async {
                    Navigator.of(context).pop();

                    final errorMessage = await ref
                        .read(fotoMenuProvider.notifier)
                        .pickFoto(ImageSource.camera);

                    if (errorMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    ;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitData() async {
    final fotoMenu = ref.read(fotoMenuProvider);
    if (namaRestoController.text.isEmpty ||
        kategoriController.text.isEmpty ||
        alamatController.text.isEmpty ||
        _latitude == null ||
        _longitude == null ||
        fotoMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lengkapi semua data, lokasi, dan minimal 1 foto!',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(restoControllerProvider)
          .submitResto(
            isEdit: widget.isEdit,
            docId: widget.docId,
            nama: namaRestoController.text,
            kategori: kategoriController.text,
            alamat: alamatController.text,
            detailAlamat: detailAlamatController.text,
            latitude: _latitude!,
            longitude: _longitude!,
            fotoMenu: fotoMenu,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil! Request restoran sedang diproses.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengirim request'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoMenu = ref.watch(fotoMenuProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isEdit ? 'Edit Restoran' : 'Tambah Restoran',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _buildSectionHeader('INFORMASI RESTORAN'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        'NAMA RESTORAN',
                        'Masukkan nama restoran',
                        false,
                        true,
                        namaRestoController,
                      ),
                      _buildInputField(
                        'KATEGORI',
                        'Misal: Kopi, Mie, Nasi Padang',
                        true,
                        true,
                        kategoriController,
                      ),
                    ],
                  ),
                ),
                _buildSectionHeader('LOKASI'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _isLoadingLocation ? null : _getCurrentLocation,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildMapBlock(60, 40),
                                      _buildMapBlock(80, 40),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildMapBlock(100, 30),
                                      _buildMapBlock(100, 50),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildMapBlock(50, 40),
                                      _buildMapBlock(50, 60),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const Positioned(
                                top: 35,
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'ALAMAT',
                        'Masukkan alamat melalui titik lokasi di atas',
                        true,
                        true,
                        alamatController,
                        enabled: false,
                      ),
                      const SizedBox(height: 8),
                      _buildInputField(
                        'DETAIL ALAMAT',
                        'Masukkan detail jalan/gedung',
                        true,
                        false,
                        detailAlamatController,
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: [
                          Center(
                            child: TextButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _getCurrentLocation,
                              icon: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.refresh,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                              label: Text(
                                _isLoadingLocation
                                    ? 'Mencari lokasi...'
                                    : 'Atur ulang titik lokasi',
                                style: TextStyle(
                                  color: _isLoadingLocation
                                      ? AppColors.textHint
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          if (_latitude != null && _longitude != null) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => openOnGoogleMaps(
                                  _latitude,
                                  _longitude,
                                  context,
                                ),
                                icon: const Icon(
                                  Icons.map,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Lihat di Google Maps',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSectionHeader('FOTO MENU'),
                InkWell(
                  onTap: _tampilkanMenuFoto,
                  child: CustomDashedBorder(
                    color: AppColors.textHint,
                    strokeWidth: 1.5,
                    radius: 12.0,
                    dashPattern: const [6.0, 4.0],
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textSecondary,
                            size: 36,
                          ),
                          SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              text: 'Tap untuk unggah foto menu',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 4),
                          Text(
                            'Maks 2MB',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < fotoMenu.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _buildPhotoTile(i, fotoMenu[i]),
                        ),

                      GestureDetector(
                        onTap: () {
                          _tampilkanMenuFoto();
                        },
                        child: CustomDashedBorder(
                          color: AppColors.textHint,
                          strokeWidth: 1.5,
                          radius: 12.0,
                          dashPattern: const [6.0, 4.0],
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: AppColors.textHint,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.cardColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : Text(
                        'Kirim Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    bool isLast,
    bool isrequired,
    TextEditingController? controller, {
    bool? enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
            children: [
              if (isrequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),

        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 4),
          const Divider(color: AppColors.background, height: 1, thickness: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildPhotoTile(int index, dynamic file) {
    final fotoMenu = ref.read(fotoMenuProvider);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) =>
                  OpenFullPhoto(foto: fotoMenu, initialPage: index),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file is File
                ? Image.file(file, width: 100, height: 100, fit: BoxFit.cover)
                : Image.network(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                ref.read(fotoMenuProvider.notifier).hapusFoto(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapBlock(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class CustomDashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern;

  const CustomDashedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.radius = 0.0,
    this.dashPattern = const [6.0, 4.0],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern;

  _DashedPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashPattern[0]),
          Offset.zero,
        );
        distance += dashPattern[0] + dashPattern[1];
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
