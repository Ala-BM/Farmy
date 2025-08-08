import 'package:farmy/src/Home_pages/Drawer_chat.dart';
import 'package:farmy/src/blocs/crops/crop_bloc.dart';
import 'package:farmy/src/blocs/crops/crop_event.dart';
import 'package:farmy/src/blocs/crops/crop_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'FarmerCropDetail.dart';

class FarmerHomescreen extends StatefulWidget {
  const FarmerHomescreen({super.key});

  @override
  State<FarmerHomescreen> createState() => _FarmerHomescreenState();
}

class _FarmerHomescreenState extends State<FarmerHomescreen> {
  static const _primaryColor = Color.fromRGBO(0, 178, 0, 1);
  static const _fontFamily = "Poppins-SemiBold";
  
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    context.read<CropBloc>().add(FetchCropsEvent(farmerUID: user?.uid));
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  void _showUpdateDialog(String docId, Map<String, dynamic> crop) {
    showDialog(
      context: context,
      builder: (context) => _UpdateCropDialog(
        docId: docId,
        crop: crop,
        onUpdate: (String cropId, Map<String, dynamic> data) {
          context.read<CropBloc>().add(UpdateCropEvent(cropId: cropId, newData: data));
        },
      ),
    );
  }


  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontFamily: _fontFamily),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: _primaryColor, fontFamily: _fontFamily),
        ),
      );
    }
  }



  void _navigateToCropDetail(Map<String, dynamic> crop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Farmercropdetailcrop(crop: crop),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Farmer DashBoard",
        style: TextStyle(
          fontSize: 20,
          fontFamily: _fontFamily,
          color: _primaryColor,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.person, color: _primaryColor),
          );
        },
      ),
    );
  }


  Widget _buildCropsList(BuildContext context, CropState state) {
    if (state is CropLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CropEmpty) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(fontSize: 16, fontFamily: _fontFamily),
        ),
      );
    }

    if (state is CropLoaded) {
      return ListView.builder(
        itemCount: state.crops.length,
        itemBuilder: (context, index) => _buildCropCard(state.crops[index]),
      );
    }

    if (state is CropUpdated) {
      return ListView.builder(
        itemCount: state.crops.length,
        itemBuilder: (context, index) => _buildCropCard(state.crops[index]),
      );
    }

    if (state is CropDeleted) {
      return ListView.builder(
        itemCount: state.crops.length,
        itemBuilder: (context, index) => _buildCropCard(state.crops[index]),
      );
    }

    if (state is CropError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return const Center(
      child: Text(
        "Unexpected Error Happened",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return InkWell(
      onTap: () => _navigateToCropDetail(crop),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(
            crop['product'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: _buildCropSubtitle(crop),
          trailing: _buildCropActions(crop),
        ),
      ),
    );
  }

  Widget _buildCropSubtitle(Map<String, dynamic> crop) {
    final subtitleData = [
      "Rating: ${crop['rating']}",
      "Farmer: ${crop['farmerName']}",
      "Cost Per Kg: ${crop['costPerKg']}",
      "Uploaded: ${crop['uploadDate']}",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtitleData
          .map((text) => Text(text, style: const TextStyle(fontSize: 14)))
          .toList(),
    );
  }

  Widget _buildCropActions(Map<String, dynamic> crop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showUpdateDialog(crop["id"], crop),
          icon: const Icon(Icons.edit, color: _primaryColor),
          tooltip: "Edit crop",
        ),
        IconButton(
          onPressed: () => _showDeleteConfirmation(crop["id"]),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: "Delete crop",
        ),
      ],
    );
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Crop"),
        content: const Text("Are you sure you want to delete this crop?"),
        actions: [
          _buildDialogButton(
            text: "Cancel",
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _buildDialogButton(
            text: "Delete",
            onPressed: () {
              Navigator.pop(context);
              context.read<CropBloc>().add(DelCropEvent(cropId: docId));
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const DrawerChat(),
      body: BlocConsumer<CropBloc, CropState>(
        listener: (context, state) {
          if (state is CropUpdated) {
            _showSnackBar(state.message, _primaryColor);
          } else if (state is CropDeleted) {
            _showSnackBar(state.message, _primaryColor);
          } else if (state is CropError) {
            _showSnackBar(state.message, Colors.red);
          }
        },
        builder: (context, state) {
          return _buildCropsList(context, state);
        },
      ),
    );
  }
}

class _UpdateCropDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> crop;
  final Function(String, Map<String, dynamic>) onUpdate;

  const _UpdateCropDialog({
    required this.docId,
    required this.crop,
    required this.onUpdate,
  });

  @override
  State<_UpdateCropDialog> createState() => _UpdateCropDialogState();
}

class _UpdateCropDialogState extends State<_UpdateCropDialog> {
  static const _primaryColor = Color.fromRGBO(0, 178, 0, 1);
  static const _fontFamily = "Poppins-SemiBold";
  
  late final TextEditingController _productController;
  late final TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.crop['product']);
    _costController = TextEditingController(text: widget.crop['costPerKg']);
  }

  @override
  void dispose() {
    _productController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontFamily: _fontFamily),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: _primaryColor, fontFamily: _fontFamily),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update Crop"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogTextField(
            controller: _productController,
            label: "Product Name",
          ),
          _buildDialogTextField(
            controller: _costController,
            label: "Cost Per Kg",
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        _buildDialogButton(
          text: "Cancel",
          onPressed: () => Navigator.pop(context),
          isPrimary: false,
        ),
        _buildDialogButton(
          text: "Update",
          onPressed: () {
            final updatedData = <String, dynamic>{
              'Product': _productController.text,
              'CostPerKg': _costController.text,
            };
            widget.onUpdate(widget.docId, updatedData);
            Navigator.pop(context);
          },
          isPrimary: true,
        ),
      ],
    );
  }
}