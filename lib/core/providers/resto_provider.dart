import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:makan_mana/core/providers/location_providers.dart';

class RestoModel {
  final String id;
  final Map<String, dynamic> data;
  final double distance;
  final String? type;

  RestoModel({
    required this.id,
    required this.data,
    required this.distance,
    this.type,
  });
}

final approvedRestoProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('request_resto')
      .where('status', isEqualTo: 'approved')
      .snapshots();
});

final pendingRestoProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('request_resto')
      .where('status', isEqualTo: 'pending')
      .snapshots();
});

final pendingEditProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('resto_edit')
      .where('status', isEqualTo: 'pending')
      .snapshots();
});

final requestRestoByUser = StreamProvider.family<QuerySnapshot, String>((
  ref,
  requestedBy,
) {
  return FirebaseFirestore.instance
      .collection('request_resto')
      .where('requestedBy', isEqualTo: requestedBy)
      .orderBy('created_at', descending: true)
      .snapshots();
});

final totalPendingListProvider = Provider<AsyncValue<List<RestoModel>>>((ref) {
  final pendingRestoAsync = ref.watch(pendingRestoProvider);
  final pendingEditAsync = ref.watch(pendingEditProvider);
  final locationAsync = ref.watch(locationProvider);

  if (pendingRestoAsync.isLoading ||
      pendingEditAsync.isLoading ||
      locationAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (pendingRestoAsync.hasError) {
    return AsyncValue.error(
      pendingRestoAsync.error!,
      pendingRestoAsync.stackTrace!,
    );
  }

  if (pendingEditAsync.hasError) {
    return AsyncValue.error(
      pendingEditAsync.error!,
      pendingEditAsync.stackTrace!,
    );
  }

  if (locationAsync.hasError) {
    return AsyncValue.error(locationAsync.error!, locationAsync.stackTrace!);
  }

  final pendingRestoDocs = pendingRestoAsync.value!.docs;
  final pendingEditDocs = pendingEditAsync.value!.docs;
  final position = locationAsync.value;

  List<RestoModel> processDocs(List<QueryDocumentSnapshot> docs, String type) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      double lat = (data['latitude'] ?? 0.0).toDouble();
      double long = (data['longitude'] ?? 0.0).toDouble();
      double jarakKm = 0.0;

      if (position != null) {
        jarakKm =
            Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              lat,
              long,
            ) /
            1000;
      }

      return RestoModel(id: doc.id, data: data, distance: jarakKm, type: type);
    }).toList();
  }

  List<RestoModel> listPending = [
    ...processDocs(pendingRestoDocs, 'request_resto'),
    ...processDocs(pendingEditDocs, 'resto_edit'),
  ];

  return AsyncValue.data(listPending);
});

final sortOptionProvider = StateProvider<String>((ref) => 'terdekat');

final sortedRestoListProvider = Provider<AsyncValue<List<RestoModel>>>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final restosAsync = ref.watch(approvedRestoProvider);
  final sortOption = ref.watch(sortOptionProvider);

  if (locationAsync.isLoading || restosAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (restosAsync.hasError) {
    return AsyncValue.error(restosAsync.error!, restosAsync.stackTrace!);
  }

  final position = locationAsync.value;
  final docs = restosAsync.value!.docs;

  List<RestoModel> listResto = docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;

    double lat = (data['latitude'] ?? 0.0).toDouble();
    double long = (data['longitude'] ?? 0.0).toDouble();
    double jarakKm = 0.0;

    if (position != null) {
      jarakKm =
          Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            lat,
            long,
          ) /
          1000;
    }

    return RestoModel(id: doc.id, data: data, distance: jarakKm);
  }).toList();

  listResto.sort((a, b) {
    if (sortOption == 'terbaru') {
      final dateA = a.data['created_at'] as Timestamp;
      final dateB = b.data['created_at'] as Timestamp;
      return dateB.compareTo(dateA);
    } else if (sortOption == 'nama') {
      final nameA = (a.data['nama_resto'] as String?) ?? '';
      final nameB = (b.data['nama_resto'] as String?) ?? '';
      return nameA.compareTo(nameB);
    } else {
      return a.distance.compareTo(b.distance);
    }
  });

  return AsyncValue.data(listResto);
});
