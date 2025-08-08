import "package:equatable/equatable.dart";

abstract class CropEvent extends Equatable {
  const CropEvent();
  @override
  List<Object?> get props => [];
}

class AddCropEvent extends CropEvent {
  final Map<String,dynamic> cropData ;
  const AddCropEvent({required this.cropData});

  @override
  List<Object> get props => [cropData];
  
}

class DelCropEvent extends CropEvent {
  final String cropId ;
  const DelCropEvent({required this.cropId});

  @override
  List<Object> get props => [cropId];
  
}

class ListenToCropsEvent extends CropEvent  {
  final String? cropType;
  final String? location;
  final double? maxPrice;
  final double? minRating;

  const ListenToCropsEvent({
    this.cropType,
    this.location,
    this.maxPrice,
    this.minRating,
  });

  @override
  List<Object?> get props => [cropType, location, maxPrice, minRating];
}

class UpdateCropEvent extends CropEvent {
  final Map<String,dynamic> newData;
  final String cropId;
  const UpdateCropEvent({required this.cropId,required this.newData});

  @override
  List<Object> get props => [cropId,newData];
  
}

class SearchCropsEvent extends CropEvent {
  final String query;
  final Map<String, dynamic>? filters;

  const SearchCropsEvent({
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [query, filters];
}
class FilterCropsEvent extends CropEvent {
  final String? cropType;
  final String? location;
  final double? maxPrice;
  final double? minRating;

  const FilterCropsEvent({
    this.cropType,
    this.location,
    this.maxPrice,
    this.minRating,
  });

  @override
  List<Object?> get props => [cropType, location, maxPrice, minRating];
}

class FetchCropsEvent extends CropEvent {
  final String? farmerUID; 
  final Map<String, dynamic>? filters; 

  const FetchCropsEvent({
    this.farmerUID,
    this.filters,
  });

  @override
  List<Object?> get props => [farmerUID, filters];
}