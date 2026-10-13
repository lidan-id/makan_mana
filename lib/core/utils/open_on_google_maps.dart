import 'package:flutter/material.dart';
import 'package:makan_mana/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openOnGoogleMaps(
  double? latitude,
  double? longitude,
  BuildContext context,
) async {
  if (latitude == null || longitude == null) return;

  final Uri googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
  );

  try {
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Maps.';
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
