import 'package:equatable/equatable.dart';

abstract class CropState extends Equatable {
  const CropState();

  @override
  List<Object?> get props => [];
}

class CropInitial extends CropState {
  const CropInitial();
}

class CropLoading extends CropState {
  const CropLoading();
}

class CropLoaded extends CropState {
  final List<Map<String, dynamic>> crops;
  final bool isFiltered;
  final String? filterDescription; 

  const CropLoaded({
    required this.crops,
    this.isFiltered = false,
    this.filterDescription,
  });

  @override
  List<Object?> get props => [crops, isFiltered, filterDescription];
}

class CropError extends CropState {
  final String message;

  const CropError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CropUpdated extends CropState {
  final String message;
  final List<Map<String, dynamic>> crops;

  const CropUpdated({
    required this.message,
    required this.crops,
  });

  @override
  List<Object?> get props => [message, crops];
}

class CropDeleted extends CropState {
  final String message;
  final List<Map<String, dynamic>> crops;

  const CropDeleted({
    required this.message,
    required this.crops,
  });

  @override
  List<Object?> get props => [message, crops];
}

class CropEmpty extends CropState {
  final String message;

  const CropEmpty({this.message = "No crops found"});

  @override
  List<Object?> get props => [message];
}