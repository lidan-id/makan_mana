import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

final fotoMenuProvider =
    StateNotifierProvider<FotoMenuController, List<dynamic>>((ref) {
      return FotoMenuController();
    });

class FotoMenuController extends StateNotifier<List<dynamic>> {
  FotoMenuController() : super([]);

  final ImagePicker _picker = ImagePicker();

  void initFotos(List<String>? initialUrls) {
    if (initialUrls != null && initialUrls.isNotEmpty) {
      state = [...initialUrls];
    }
  }

  Future<String?> pickFoto(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          imageQuality: 70,
          maxWidth: 1024,
        );

        bool adaFileKebesaran = false;
        List<File> fileLulusSensor = [];

        for (var xfile in pickedFiles) {
          File file = File(xfile.path);
          if (file.lengthSync() / (1024 * 1024) <= 2.0) {
            fileLulusSensor.add(file);
          } else {
            adaFileKebesaran = true;
          }
        }

        state = [...state, ...fileLulusSensor];

        if (adaFileKebesaran) return 'Beberapa foto ditolak karena > 2MB.';
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1024,
        );

        if (pickedFile != null) {
          File file = File(pickedFile.path);
          if (file.lengthSync() / (1024 * 1024) <= 2.0) {
            state = [...state, file];
          } else {
            return 'Foto ditolak karena > 2MB.';
          }
        }
      }
      return null;
    } catch (e) {
      return 'Gagal mengambil foto: $e';
    }
  }

  void hapusFoto(int index) {
    final listBaru = List<dynamic>.from(state);
    listBaru.removeAt(index);
    state = listBaru;
  }
}
