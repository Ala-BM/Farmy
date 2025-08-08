import 'package:farmy/src/Landing_pages/buyer_pages/buyer_login.dart';
import 'package:farmy/src/Landing_pages/farmer_pages/Farmer_login.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  static const String _fontFamily = 'Poppins-SemiBold';
  static const String _appLogoPath = "assets/images/main.jpg";
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom,
              child: _buildMainContent(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8FFF8),
          Color(0xFFE8F5E8),
        ],
        stops: [0.0, 1.0],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildWelcomeHeader(),
              _buildAppLogo(),
              Column(
                children: [
                  _buildAppTitle(),
                  const SizedBox(height: 16),
                  _buildAppSubtitles(),
                ],
              ),
              _builduserTypeButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          "Welcome to",
          style: TextStyle(
            fontSize: 28,
            color: Colors.grey[700],
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primaryGreen.withOpacity(0.3),
                _primaryGreen,
                _primaryGreen.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildAppLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        height: 220,
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            _appLogoPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(
          Icons.agriculture,
          size: 100,
          color: _primaryGreen,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          _primaryGreen,
          _primaryGreen.withOpacity(0.8),
        ],
      ).createShader(bounds),
      child: const Text(
        "Farmy",
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  Widget _buildAppSubtitles() {
    return Column(
      children: [
        Text(
          "From Farm to Business",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Sell Smarter, Grow Bigger!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _builduserTypeButtons() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildUserTypeButton(
            title: "Are you a Farmer?",
            subtitle: "Sell your crops directly to buyers",
            icon: Icons.agriculture,
            onPressed: () => _navigateToFarmerLogin(),
            isPrimary: true,
          ),
          const SizedBox(height: 20),
          _buildUserTypeButton(
            title: "Want to buy from Farmers?",
            subtitle: "Connect directly with local farmers",
            icon: Icons.shopping_cart,
            onPressed: () => _navigateToBuyerLogin(),
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? _primaryGreen : Colors.white,
          foregroundColor: isPrimary ? Colors.white : _primaryGreen,
          elevation: isPrimary ? 8 : 4,
          shadowColor: _primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary 
              ? BorderSide.none 
              : BorderSide(color: _primaryGreen, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary 
                  ? Colors.white.withOpacity(0.2)
                  : _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isPrimary ? Colors.white : _primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : _primaryGreen,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPrimary 
                        ? Colors.white.withOpacity(0.9)
                        : _primaryGreen.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isPrimary 
                ? Colors.white.withOpacity(0.8)
                : _primaryGreen.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFarmerLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const FarmerLogin(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.ease)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToBuyerLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const BuyerLogin(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.ease)),
            ),
            child: child,
          );
        },
      ),
    );
  }
}