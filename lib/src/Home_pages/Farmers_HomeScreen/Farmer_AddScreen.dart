import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:farmy/src/blocs/crops/crop_bloc.dart';
import 'package:farmy/src/blocs/crops/crop_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/Farm_pages_utils/Add_Crop_Utils.dart';

class FarmerAddscreen extends StatefulWidget {
  const FarmerAddscreen({super.key});

  @override
  State<FarmerAddscreen> createState() => _FarmerAddscreenState();
}

class _FarmerAddscreenState extends State<FarmerAddscreen> {
  final _controllers = {
    'product': TextEditingController(),
    'availability': TextEditingController(),
    'costPerKg': TextEditingController(),
    'harvestDate': TextEditingController(),
    'expiryDate': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'farmerName': TextEditingController(),
  };

  String _cropType = '';
  String _cropRating = "";
  String _priceType = '';
  String _location = "";
  final String _cropUploadedDate =
      DateFormat('dd-MM-yyyy').format(DateTime.now());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const _primaryColor = Color.fromRGBO(0, 178, 0, 1);
  static const _fontFamily = "Poppins-SemiBold";

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _getLocation() async {
    String location = await getCurrentLocation();
    setState(() => _location = location);
  }

  void _clearForm() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _cropType = "";
      _cropRating = '';
      _priceType = "";
    });
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    String? helperText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: controller,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              label: Text(label),
              labelStyle:
                  const TextStyle(color: Colors.black, fontFamily: _fontFamily),
              prefixIcon: prefixIcon,
              enabledBorder: buildOutlineInputBorder(Colors.grey),
              focusedBorder: buildOutlineInputBorder(_primaryColor),
              errorBorder: buildOutlineInputBorder(Colors.red),
              focusedErrorBorder: buildOutlineInputBorder(Colors.red),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
            child: Text(
              " * $helperText",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Your Crop",
          style: TextStyle(color: _primaryColor, fontFamily: _fontFamily),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _controllers['farmerName']!,
                label: "Farmer Name",
                validator: (value) => validateRequired(value, "Farmer Name"),
                helperText: "Please Enter Valid Farmer Name",
              ),
              _buildTextFormField(
                controller: _controllers['phoneNumber']!,
                label: "Phone Number",
                validator: validatePhoneNumber,
                helperText:
                    "Please Enter Valid PhoneNumber with your country code",
              ),
              _buildTextFormField(
                controller: _controllers['product']!,
                label: "Product",
                validator: (value) => validateRequired(value, "Product"),
                helperText: "Please Mention Crops Like Potatoes Or Tomatoes.",
              ),
              _buildTextFormField(
                controller: _controllers['availability']!,
                label: "Availability",
                validator: (value) => validateRequired(value, "Availability"),
                helperText: "Please Mention Availability in Kgs.",
              ),
              _buildTextFormField(
                controller: _controllers['costPerKg']!,
                label: "Cost Per Kg",
                validator: (value) => validateRequired(value, "Cost Per Kg"),
                helperText: "Expecting Cost per Kg",
              ),
              buildCheckboxRow(["Fixed Price", "Negotiable"], _priceType,
                  (value) => setState(() => _priceType = value)),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(" * Select the Price Type",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              buildCheckboxRow(["Organic", "Hybrid"], _cropType,
                  (value) => setState(() => _cropType = value)),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                child: Text(
                  " * Please Click The Checkbox To Select The Crop Variety",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              _buildTextFormField(
                controller: _controllers['harvestDate']!,
                label: "Harvest Date",
                validator: (value) => null, 
                readOnly: true,
                onTap: () {
                  selectDate(
                      context: context,
                      controller: _controllers['harvestDate']!,
                      fallbackText: "Farmer Not Mentioned");
                  setState(() {});
                },
                prefixIcon: const Icon(Icons.date_range),
              ),
              _buildTextFormField(
                controller: _controllers['expiryDate']!,
                label: "Expiry Date",
                validator: (value) => null, 
                readOnly: true,
                onTap: () {
                  selectDate(
                      context: context,
                      controller: _controllers['expiryDate']!,
                      fallbackText: "Farmer Not Mentioned");
                  setState(() {});
                },
                prefixIcon: const Icon(Icons.date_range),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 10),
                child: RatingBar(
                  filledColor: _primaryColor,
                  size: 40,
                  filledIcon: Icons.star,
                  emptyIcon: Icons.star_border,
                  onRatingChanged: (rating) => _cropRating = rating.toString(),
                  initialRating: 0,
                  maxRating: 5,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(" * Rate your crop from 1 to 5.",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final cropData = <String, dynamic>{
                          "Product": _controllers['product']!.text.trim(),
                          "Availability":
                              _controllers['availability']!.text.trim(),
                          "CostPerKg": _controllers['costPerKg']!.text.trim(),
                          "HarvestDate":
                              _controllers['harvestDate']!.text.trim(),
                          "ExpiryDate": _controllers['expiryDate']!.text.trim(),
                          "FarmerName": _controllers['farmerName']!.text.trim(),
                          "Croptype": _cropType,
                          "CropRating": _cropRating,
                          "CropUploadedDate": _cropUploadedDate,
                          "PriceType": _priceType,
                          "PhoneNumber":
                              _controllers['phoneNumber']!.text.trim(),
                          "Location": _location,
                          "FarmerUID": FirebaseAuth.instance.currentUser?.uid,
                        };
                        context
                            .read<CropBloc>()
                            .add(AddCropEvent(cropData: cropData));

                        context.read<CropBloc>().add(FetchCropsEvent(
                            farmerUID: FirebaseAuth.instance.currentUser?.uid));
                        _clearForm();
                      }
                    },
                    child: const Text(
                      "Submit My Crop",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
