import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'crop_event.dart';
import 'crop_state.dart';

class CropBloc extends Bloc<CropEvent, CropState> {
  StreamSubscription? _subscription;
  CropBloc() : super(const CropInitial()) {
    on<AddCropEvent>(_onAddCropEvent);
    on<DelCropEvent>(_onDelCropEvent);
    on<UpdateCropEvent>(_onUpdateCropEvent);
    on<FetchCropsEvent>(_onFetchCropEvent);
    on<SearchCropsEvent>(_onSearchCropsEvent);
    on<FilterCropsEvent>(_onFilterCropsEvent);
    on<ListenToCropsEvent>(_onListenToCropsEvent);
  }
  String _getFilterDescription(FetchCropsEvent? fetchEvent,
      {FilterCropsEvent? filterEvent}) {
    if (fetchEvent?.farmerUID != null) {
      return "Your crops";
    }

    if (filterEvent != null) {
      final filters = <String>[];
      if (filterEvent.cropType != null) {
        filters.add("Type: ${filterEvent.cropType}");
      }
      if (filterEvent.location != null) {
        filters.add("Location: ${filterEvent.location}");
      }
      if (filterEvent.maxPrice != null) {
        filters.add("Max price: €${filterEvent.maxPrice}");
      }
      if (filterEvent.minRating != null) {
        filters.add("Min rating: ${filterEvent.minRating}");
      }

      return filters.isEmpty
          ? "All crops"
          : "Filtered by: ${filters.join(', ')}";
    }

    return "All crops";
  }

  static const Map<String, String> _fieldMappings = {
    'id': 'id',
    'product': 'Product',
    'rating': 'CropRating',
    'costPerKg': 'CostPerKg',
    'availability': 'Availability',
    'cropType': 'Croptype',
    'harvestDate': 'HarvestDate',
    'expiryDate': 'ExpiryDate',
    'phoneNumber': 'PhoneNumber',
    'farmerName': 'FarmerName',
    'uploadDate': 'CropUploadedDate',
    'priceType': 'PriceType',
    'location': 'Location',
  };
  Map<String, dynamic> _mapDocumentToCrop(DocumentSnapshot doc) {
    return {
      'id': doc.id,
      'product': doc[_fieldMappings['product']!],
      'rating': doc[_fieldMappings['rating']!],
      'costPerKg': doc[_fieldMappings['costPerKg']!],
      'availability': doc[_fieldMappings['availability']!],
      'cropType': doc[_fieldMappings['cropType']!],
      'harvestDate': doc[_fieldMappings['harvestDate']!],
      'expiryDate': doc[_fieldMappings['expiryDate']!],
      'phoneNumber': doc[_fieldMappings['phoneNumber']!],
      'farmerName': doc[_fieldMappings['farmerName']!],
      'uploadDate': doc[_fieldMappings['uploadDate']!],
      'priceType': doc[_fieldMappings['priceType']!],
      'location': doc[_fieldMappings['location']!],
    };
  }

  Future<List<Map<String, dynamic>>> _getCurrentUserCrops() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    Query query = FirebaseFirestore.instance
        .collection("CropMain")
        .where("FarmerUID", isEqualTo: user.uid);

    final cropSnapshot = await query.get();
    final fetchedCrops =
        cropSnapshot.docs.map((doc) => _mapDocumentToCrop(doc)).toList();

    fetchedCrops.sort((a, b) => _compareUploadDates(a, b));
    return fetchedCrops;
  }

  Future<void> _onDelCropEvent(
      DelCropEvent event, Emitter<CropState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection("CropMain")
          .doc(event.cropId)
          .delete();

      final updatedCrops = await _getCurrentUserCrops();
      emit(CropDeleted(
        message: "Crop deleted successfully!",
        crops: updatedCrops,
      ));
    } catch (e) {
      emit(const CropError(message: "Failed to delete crop!"));
    }
  }

  Future<void> _onUpdateCropEvent(
      UpdateCropEvent event, Emitter<CropState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection("CropMain")
          .doc(event.cropId)
          .update(event.newData);

      final updatedCrops = await _getCurrentUserCrops();
      emit(CropUpdated(
        message: "Crop updated successfully!",
        crops: updatedCrops,
      ));
    } catch (e) {
      emit(const CropError(message: "Failed to update crop!"));
    }
  }

  Future<void> _onAddCropEvent(
      AddCropEvent event, Emitter<CropState> emit) async {

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const CropError(message: "No Logged in User"));
        return;
      }

      final docRef =
          await FirebaseFirestore.instance.collection("CropMain").add({
        ...event.cropData,
        "FarmerUID": user.uid,
        "CropUploadedDate": DateFormat('dd-MM-yyyy').format(DateTime.now())
      });

      await docRef.get();

      Query query = FirebaseFirestore.instance
          .collection("CropMain")
          .where("FarmerUID", isEqualTo: user.uid);

      final cropSnapshot = await query.get();

      final fetchedCrops =
          cropSnapshot.docs.map((doc) => _mapDocumentToCrop(doc)).toList();
      fetchedCrops.sort((a, b) => _compareUploadDates(a, b));

      if (fetchedCrops.isEmpty) {
        emit(const CropEmpty());
      } else {
        final newState = CropLoaded(
          crops: fetchedCrops,
          isFiltered: true,
          filterDescription: "Your crops",
        );
        emit(newState);
      }
    } on FirebaseException catch (e) {
      emit(CropError(message: e.message ?? "An error occurred"));
    } catch (e) {
      emit(const CropError(message: "An unexpected error occurred"));
    }
  }

  Future<void> _onFetchCropEvent(
      FetchCropsEvent event, Emitter<CropState> emit) async {
    emit(const CropLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const CropError(message: "User not logged in"));
        return;
      }

      Query query = FirebaseFirestore.instance.collection("CropMain");
      if (event.farmerUID != null) {
        query = query.where("FarmerUID", isEqualTo: event.farmerUID);
      }

      if (event.filters != null) {
        event.filters!.forEach((field, value) {
          if (value != null) {
            query = query.where(field, isEqualTo: value);
          }
        });
      }

      final cropSnapshot = await query.get();
  
      final fetchedCrops =
          cropSnapshot.docs.map((doc) => _mapDocumentToCrop(doc)).toList();
      fetchedCrops.sort((a, b) => _compareUploadDates(a, b));

      if (fetchedCrops.isEmpty) {
        emit(const CropEmpty());
      } else {
        final newState = CropLoaded(
          crops: fetchedCrops,
          isFiltered: event.farmerUID != null || event.filters != null,
          filterDescription: _getFilterDescription(event),
        );
        emit(newState);
      }
    } on FirebaseException catch (e) {
      final errorMessage = e.message ?? "Firebase error occurred";
      emit(CropError(message: errorMessage));
    } catch (e) {
      const errorMessage = "An unexpected error occurred";
      emit(const CropError(message: errorMessage));
    }
  }

  Future<void> _onSearchCropsEvent(
    SearchCropsEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(const CropLoading());

    try {
      Query query = FirebaseFirestore.instance.collection("CropMain");
      if (event.filters != null) {
        event.filters!.forEach((field, value) {
          if (value != null) {
            query = query.where(field, isEqualTo: value);
          }
        });
      }

      final cropSnapshot = await query.get();

      final allCrops =
          cropSnapshot.docs.map((doc) => _mapDocumentToCrop(doc)).toList();

      final searchResults = allCrops.where((crop) {
        final searchTerm = event.query.toLowerCase();
        return crop['product'].toString().toLowerCase().contains(searchTerm) ||
            crop['farmerName'].toString().toLowerCase().contains(searchTerm) ||
            crop['location'].toString().toLowerCase().contains(searchTerm) ||
            crop['cropType'].toString().toLowerCase().contains(searchTerm);
      }).toList();

      searchResults.sort((a, b) => _compareUploadDates(a, b));

      if (searchResults.isEmpty) {
        emit(CropEmpty(message: "No crops found for '${event.query}'"));
      } else {
        emit(CropLoaded(
          crops: searchResults,
          isFiltered: true,
          filterDescription: "Search results for '${event.query}'",
        ));
      }
    } on FirebaseException catch (e) {
      emit(CropError(message: e.message ?? "Search failed"));
    } catch (e) {
      emit(const CropError(message: "Search failed"));
    }
  }

  Future<void> _onFilterCropsEvent(
    FilterCropsEvent event,
    Emitter<CropState> emit,
  ) async {
    emit(const CropLoading());

    try {
      Query query = FirebaseFirestore.instance.collection("CropMain");

      if (event.cropType != null) {
        query =
            query.where(_fieldMappings['cropType']!, isEqualTo: event.cropType);
      }
      if (event.location != null) {
        query =
            query.where(_fieldMappings['location']!, isEqualTo: event.location);
      }

      final cropSnapshot = await query.get();

      var filteredCrops =
          cropSnapshot.docs.map((doc) => _mapDocumentToCrop(doc)).toList();
      if (event.maxPrice != null) {
        filteredCrops = filteredCrops.where((crop) {
          final price = double.tryParse(crop['costPerKg'].toString()) ?? 0.0;
          return price <= event.maxPrice!;
        }).toList();
      }

      if (event.minRating != null) {
        filteredCrops = filteredCrops.where((crop) {
          final rating = double.tryParse(crop['rating'].toString()) ?? 0.0;
          return rating >= event.minRating!;
        }).toList();
      }

      filteredCrops.sort((a, b) => _compareUploadDates(a, b));
      if (filteredCrops.isEmpty) {
        emit(const CropEmpty(message: "No crops match your filters"));
      } else {
        emit(CropLoaded(
          crops: filteredCrops,
          isFiltered: true,
          filterDescription: _getFilterDescription(null, filterEvent: event),
        ));
      }
    } on FirebaseException catch (e) {
      emit(CropError(message: e.message ?? "Filtering failed"));
    } catch (e) {
      emit(const CropError(message: "Filtering failed"));
    }
  }

 Future<void> _onListenToCropsEvent(
    ListenToCropsEvent event, Emitter<CropState> emit) async {
  emit(const CropLoading());
  await _subscription?.cancel();

_subscription = FirebaseFirestore.instance.collection("CropMain").snapshots().listen(
  (snapshot) {
  
      if (snapshot.docs.isEmpty) {
        emit(const CropEmpty());
      } else {
        add(const FetchCropsEvent());
      }
    },
    onError: (error) {
      if (!emit.isDone) {
        emit(CropError(message: error.toString()));
      }
    },
  );
}


  int _compareUploadDates(Map<String, dynamic> a, Map<String, dynamic> b) {
    final dateA = _parseDate(a['uploadDate']);
    final dateB = _parseDate(b['uploadDate']);
    return dateB.compareTo(dateA);
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat("dd-MM-yyyy").parse(dateString);
    } catch (e) {
      return DateTime(2000, 1, 1);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
