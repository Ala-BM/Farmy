import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmy/firebase_options.dart';
import 'package:farmy/src/Home_pages/Buyer_HomeScreen/Buyer_Main_Home.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/Farmers_Main_Home.dart';
import 'package:farmy/src/Landing_pages/welcome.dart';
import 'package:farmy/src/blocs/chat/chat_bloc.dart';
import 'package:farmy/src/blocs/crops/crop_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FarmyApp());
}

class FarmyApp extends StatelessWidget {
  const FarmyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CropBloc(),
        ),
        BlocProvider(
          create: (context) => ChatBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Farmy',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentUser = user;
              _isInitialized = true;
            });
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }
    if (_currentUser == null) {
      return const WelcomeWrapper();
    }
    
    //determine user role
    return UserRoleHandler(user: _currentUser!);
  }
}
class WelcomeWrapper extends StatefulWidget {
  const WelcomeWrapper({super.key});

  @override
  State<WelcomeWrapper> createState() => _WelcomeWrapperState();
}

class _WelcomeWrapperState extends State<WelcomeWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Welcome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class UserRoleHandler extends StatefulWidget {
  final User user;
  
  const UserRoleHandler({super.key, required this.user});

  @override
  State<UserRoleHandler> createState() => _UserRoleHandlerState();
}

class _UserRoleHandlerState extends State<UserRoleHandler> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          if (snapshot.hasError) {
            debugPrint("Error fetching user data: ${snapshot.error}");
          }
          return const WelcomeWrapper();
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final userType = userData['role'] as String?;
        
        return _buildHomeScreen(userType);
      },
    );
  }

  Widget _buildHomeScreen(String? userType) {
    switch (userType) {
      case "farmer":
        return const FarmersMainHome();
      case "buyer":
        return const BuyerMainHome();
      default:
        return const WelcomeWrapper();
    }
  }
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      body:  const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/iconLogo.png'),height: 100,width: 100,),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}