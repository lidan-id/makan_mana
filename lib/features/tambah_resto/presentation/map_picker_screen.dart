import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import '../../../core/theme/app_colors.dart';

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Titik Lokasi'),
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.textPrimary,
      ),
      body: OpenStreetMapSearchAndPick(
        buttonColor: AppColors.primary,
        buttonText: 'Pilih Lokasi Ini',
        onPicked: (pickedData) {
          Navigator.pop(context, pickedData);
        },
      ),
    );
  }
}
