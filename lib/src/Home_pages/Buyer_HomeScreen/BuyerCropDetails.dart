import 'package:farmy/src/Home_pages/Chat_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmy/src/blocs/chat/chat_bloc.dart';
import 'package:farmy/src/blocs/chat/chat_event.dart';
import 'package:farmy/src/blocs/chat/chat_state.dart';
// Import your ChatScreen here
// import 'package:farmy/src/screens/chat/chat_screen.dart';

class CropDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cropDetails;

  const CropDetailsPage({super.key, required this.cropDetails});

  @override
  State<CropDetailsPage> createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  static const String _fontFamily = 'Poppins-SemiBold';
  bool _isCreatingChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 178, 0, 1),
        title: Text(
          widget.cropDetails["Product"] ?? "Crop Details",
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins-SemiBold'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            if (mounted) {
              setState(() {
                _isCreatingChat = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is ChatSLoaded) {
            // Chat created successfully, navigate to the new chat
            if (mounted) {
              setState(() {
                _isCreatingChat = false;
              });
              _handleChatCreated(state.chats);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detailRow("Product", widget.cropDetails["product"]),
                  detailRow("Availability", "${widget.cropDetails["availability"]}"),
                  detailRow("Cost Per Kg", "€${widget.cropDetails["costPerKg"]}"),
                  detailRow("Crop Rating", widget.cropDetails["rating"]),
                  detailRow("Crop Type", widget.cropDetails["cropType"]),
                  detailRow("Uploaded Date", widget.cropDetails["uploadDate"]),
                  detailRow("Harvest Date", widget.cropDetails["harvestDate"]),
                  detailRow("Expiry Date", widget.cropDetails["expiryDate"]),
                  detailRow("Price Type", widget.cropDetails["priceType"]),
                  detailRow("Location", widget.cropDetails["location"]),
                  detailRow("Phone Number", widget.cropDetails["phoneNumber"]),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildChatButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    final currentUser = FirebaseAuth.instance.currentUser;
 
    if (currentUser == null ) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: _isCreatingChat ? null : () => _initiateChatWithFarmer(),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: _isCreatingChat
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Starting chat...",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: _fontFamily,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          : const Text(
              "Chat with The Farmer",
              style: TextStyle(
                color: Colors.white,
                fontFamily: _fontFamily,
                fontSize: 16,
              ),
            ),
    );
  }

  Future<void> _initiateChatWithFarmer() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    // Using document ID as temporary farmer ID
    final cropDocId = widget.cropDetails["id"];
    
    if (currentUser == null ) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to start chat. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isCreatingChat = true;
      });
    }

    try {
      // Get the actual farmer userId from the crop document
      final farmerId = await _getFarmerIdFromCrop(cropDocId);
      
      if (farmerId == null) {
        throw Exception("Could not find farmer information");
      }
      
      if (farmerId == currentUser.uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You cannot chat with yourself!"),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isCreatingChat = false;
          });
        }
        return;
      }

      // Use ChatBloc to create new chat
      if (mounted) {
        print("${currentUser.uid} nnnnnn $farmerId");
        context.read<ChatBloc>().add(NewChatEvent(
          currentUser.uid,
           farmerId,
        ));
        
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingChat = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start chat: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _getFarmerIdFromCrop(String cropDocId) async {
    try {
      final cropDoc = await FirebaseFirestore.instance
          .collection("CropMain") // Use your actual collection name
          .doc(cropDocId)
          .get();
      
      if (cropDoc.exists) {
        final data = cropDoc.data();
        return data?['FarmerUID'];
      }
      return null;
    } catch (e) {
      print("Error getting farmer ID: $e");
      return null;
    }
  }
    Future<String> _getUserDisplayName(String userId) async {
  final userDoc = await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .get();

  if (userDoc.exists) {
    final user = userDoc.data();
    return user?["name"] ?? "No name field found";
  } else {
    return "No user found with that UID";
  }
}

  Future<void> _handleChatCreated(List<Map<String, dynamic>> chats) async {
    if (chats.isNotEmpty) {
      final newChat = chats.first; 
      final chatId = newChat['id'];
      final participants = List<String>.from(newChat['participants'] ?? []);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => 'Unknown',
      );
      
      final otherUserName = await _getUserDisplayName(otherUserId);
      
   
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              otherUserName: otherUserName,
            ),
          ),
        );
      }
      

    }
  }

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}