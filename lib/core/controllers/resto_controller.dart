import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final restoControllerProvider = Provider<RestoController>((ref) {
  return RestoController();
});

class RestoController {
  Future<void> submitResto({
    required bool isEdit,
    required String? docId,
    required String nama,
    required String kategori,
    required String alamat,
    required String detailAlamat,
    required double latitude,
    required double longitude,
    required List<dynamic> fotoMenu,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Pengguna tidak ditemukan. Silakan login ulang.');
    }

    final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    List<String> daftarUrlFoto = [];

    for (var item in fotoMenu) {
      if (item is String) {
        daftarUrlFoto.add(item);
      } else if (item is File) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            item.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'request_resto_photos',
          ),
        );
        daftarUrlFoto.add(response.secureUrl);
      }
    }

    final data = {
      if (isEdit) 'request_resto_id': docId,
      'nama_resto': nama,
      'kategori': kategori,
      'alamat': alamat,
      'detail_alamat': detailAlamat,
      'latitude': latitude,
      'longitude': longitude,
      'foto_urls': daftarUrlFoto,
      'status': 'pending',
      'requestedBy': user.uid,
      'requestedByEmail': user.email,
      'requestedByName': user.displayName,
      'created_at': FieldValue.serverTimestamp(),
    };

    final collection = isEdit ? 'resto_edit' : 'request_resto';
    await FirebaseFirestore.instance.collection(collection).add(data);
  }

  Future<void> approveResto(String docId, String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .update({'status': 'approved'});
    } catch (e) {
      throw Exception('Gagal menyetujui permintaan');
    }
  }

  Future<void> approveEditResto(
    String editRequestId,
    Map<String, dynamic> editData,
  ) async {
    try {
      final String? targetRestoId = editData['request_resto_id'];

      if (targetRestoId == null || targetRestoId.isEmpty) {
        throw Exception('ID request_resto tidak ditemukan.');
      }

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final targetRestoRef = firestore
          .collection('request_resto')
          .doc(targetRestoId);

      batch.update(targetRestoRef, {
        'nama_resto': editData['nama_resto'],
        'alamat': editData['alamat'],
        'detail_alamat': editData['detail_alamat'],
        'kategori': editData['kategori'],
        'foto_urls': editData['foto_urls'],
        'latitude': editData['latitude'],
        'longitude': editData['longitude'],
      });

      final editRequestRef = firestore
          .collection('resto_edit')
          .doc(editRequestId);
      batch.update(editRequestRef, {'status': 'approved'});

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menyetujui edit: $e');
    }
  }

  Future<void> deleteResto(String docId, String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .update({'status': 'deleted'});
    } catch (e) {
      throw Exception('Gagal menghapus restoran');
    }
  }
}
