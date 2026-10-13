import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/determine_position.dart';

final locationProvider = FutureProvider<Position?>((ref) async {
  return await determinePosition();
});
