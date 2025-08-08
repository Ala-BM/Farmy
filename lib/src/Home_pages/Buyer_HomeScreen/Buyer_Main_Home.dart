import 'package:farmy/src/blocs/crops/crop_bloc.dart';
import 'package:farmy/src/blocs/crops/crop_event.dart';
import 'package:farmy/src/blocs/crops/crop_state.dart';
import 'package:farmy/src/Home_pages/Buyer_HomeScreen/Buyers_Screen_utils/Buyer_Screen_Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'BuyerCropDetails.dart';
import '../Drawer_chat.dart';

class BuyerMainHome extends StatefulWidget {
  const BuyerMainHome({super.key});

  @override
  State<BuyerMainHome> createState() => _BuyerMainHomeState();
}

class _BuyerMainHomeState extends State<BuyerMainHome> {
  static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  static const String _fontFamily = 'Poppins-SemiBold';

  @override
  void initState() {
    super.initState();
    context.read<CropBloc>().add(const ListenToCropsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const DrawerChat(), // Use the new drawer
      body: BlocBuilder<CropBloc, CropState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Buyer Dashboard",
        style: TextStyle(
          fontFamily: _fontFamily,
          color: _primaryGreen,
        ),
      ),
      titleSpacing: 0,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(
            Icons.menu, // Changed from home to menu for better UX
            color: _primaryGreen,
          ),
          tooltip: 'Open menu',
        ),
      ),
      /*actions: [
        // i should Add a notification or chat icon in app bar
        IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: _primaryGreen,
          ),
          tooltip: 'Open chats',
        ),
      ],*/
    );
  }

  Widget _buildBody(BuildContext context, CropState state) {
    if (state is CropLoading) {
      return _buildLoadingState();
    } else if (state is CropError) {
      return _buildErrorState(state.message);
    } else if (state is CropEmpty) {
      return _buildEmptyState();
    } else if (state is CropLoaded) {
      return _buildCropGrid(state.crops);
    } else {
      return const SizedBox.shrink(); // fallback
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _primaryGreen,
          ),
          SizedBox(height: 16),
          Text(
            "Loading crops...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry loading crops
              context.read<CropBloc>().add(const ListenToCropsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            color: Colors.grey,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            "No crops available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Check back later for new listings",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropGrid(List<Map<String, dynamic>> cropData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.85,
        ),
        itemCount: cropData.length,
        itemBuilder: (context, index) {
          return _buildCropCard(cropData[index]);
        },
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> cropData) {
    return GestureDetector(
      onTap: () => _navigateToCropDetails(cropData),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCropIcon(),
                const SizedBox(height: 12),
                _buildCropTitle(cropData),
                const SizedBox(height: 8),
                _buildCropInfo(cropData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.eco,
        color: _primaryGreen,
        size: 24,
      ),
    );
  }

  Widget _buildCropTitle(Map<String, dynamic> cropData) {
    return Text(
      getCropProduct(cropData),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: _primaryGreen,
        fontFamily: _fontFamily,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCropInfo(Map<String, dynamic> cropData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.euro,
          "${getCropCost(cropData)}/kg",
          Colors.green[700]!,
        ),
        const SizedBox(height: 4),
        _buildRatingRow(cropData),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(Map<String, dynamic> cropData) {
    final rating = getCropRating(cropData);
    return Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          rating,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToCropDetails(Map<String, dynamic> cropData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailsPage(cropDetails: cropData),
      ),
    );
  }
}