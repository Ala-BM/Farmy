
  import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "Enter $fieldName";
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter Phone Number";
    }
    if (!RegExp(r'^\+\d{7,}$').hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }
  Future<String> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return "Location services are disabled";
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      return "Location permission denied";
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        return "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      }
      return "Unable to get address";
    } catch (e) {
      return "Error getting location: ${e.toString()}";
    }
  }

  
Future<void> selectDate({
  required BuildContext context,
  required TextEditingController controller,
  required String fallbackText,
}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    firstDate: DateTime(2024),
    lastDate: DateTime(2026),
    initialDate: DateTime.now(),
  );

  if (pickedDate != null) {
    controller.text = "${pickedDate.day.toString().padLeft(2, '0')}/"
        "${pickedDate.month.toString().padLeft(2, '0')}/"
        "${pickedDate.year}";
  } else {
    controller.text = fallbackText;
  }
}

 OutlineInputBorder buildOutlineInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: color),
    );
  }

    Widget _buildCheckbox(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              color: isSelected ? Colors.green : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget buildCheckboxRow(List<String> options, String currentValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: options.map((option) => 
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildCheckbox(option, currentValue == option, () => onChanged(option)),
          )
        ).toList(),
      ),
    );
  }