import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makan_mana/core/utils/load_user_data.dart';

final userDataProvider = FutureProvider<UserData>((ref) async {
  return await loadUserData();
});
