import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerSignup extends StatefulWidget {
  const FarmerSignup({super.key});

  @override
  State<FarmerSignup> createState() => _FarmerSignupState();
}

class _FarmerSignupState extends State<FarmerSignup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final List<String> _farmTypes = [
    'Crop Farming',
    'Dairy Farming',
    'Poultry Farming',
    'Mixed Farming',
    'Organic Farming',
    'Greenhouse Farming',
    'Livestock Farming',
    'Other'
  ];
  String? _selectedFarmType;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  String? _validateFarmName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Farm name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Farm name must be at least 2 characters';
    }
    
    return null;
  }
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.trim().length < 3) {
      return 'Please enter a valid location';
    }
    
    return null;
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  String? _validateFarmType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your farm type';
    }
    return null;
  }

  Future<void> _signupWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFarmType == null) {
      _showErrorSnackBar('Please select your farm type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        await FirebaseFirestore.instance.collection("users").doc(userId).set({
          "email": _emailController.text.trim(),
          "name": _nameController.text.trim(),
          "farmName": _farmNameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "location": _locationController.text.trim(),
          "farmType": _selectedFarmType,
          "role": "farmer",
          "isVerified": false, // For future verification system
          "profileComplete": true,
          "createdAt": FieldValue.serverTimestamp(),
          "lastLoginAt": FieldValue.serverTimestamp(),
        });
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("farmerProfile")//for future farm database
            .doc("details")
            .set({
          "farmSize": null, 
          "experience": null, 
          "certifications": [], 
          "products": [], 
          "description": null, 
          "images": [], 
          "rating": 0.0,
          "totalSales": 0,
          "profileViews": 0,
        });

        if (mounted) {
          _showSuccessSnackBar("Farmer account created successfully!");
          _clearForm();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'A farmer account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }

      if (mounted) {
        _showErrorSnackBar(errorMessage);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _showErrorSnackBar('Database error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
    _farmNameController.clear();
    _phoneController.clear();
    _locationController.clear();
    setState(() {
      _selectedFarmType = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(76, 175, 80, 1),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 1.5,
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 2,
                color: Color.fromRGBO(76, 175, 80, 1),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 1.5,
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 2,
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: const Color.fromRGBO(76, 175, 80, 1))
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "Farm Type *",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(76, 175, 80, 1),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedFarmType,
          validator: _validateFarmType,
          decoration: InputDecoration(
            hintText: "Select your farming type",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 1.5,
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 2,
                color: Color.fromRGBO(76, 175, 80, 1),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 1.5,
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                width: 2,
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: const Icon(
              Icons.agriculture,
              color: Color.fromRGBO(76, 175, 80, 1),
            ),
          ),
          items: _farmTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFarmType = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    Color strengthColor = Colors.red;
    String strengthText = 'Weak';
    
    if (strength >= 4) {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    } else if (strength >= 3) {
      strengthColor = Colors.orange;
      strengthText = 'Medium';
    }

    return password.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Row(
              children: [
                Text(
                  'Password strength: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  strengthText,
                  style: TextStyle(
                    fontSize: 12,
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Join as Farmer",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Poppins-SemiBold",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/3.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Text(
                "Start Your Digital Farm Journey",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(76, 175, 80, 1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Connect directly with buyers and grow your business",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(76, 175, 80, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: "Full Name *",
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                      hintText: "Enter your full name",
                      prefixIcon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address *",
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      hintText: "Enter your email address",
                      prefixIcon: Icons.email_outlined,
                    ),
                    
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      label: "Phone Number *",
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      hintText: "Enter your phone number",
                      prefixIcon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 32),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Farm Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(76, 175, 80, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _farmNameController,
                      label: "Farm Name *",
                      validator: _validateFarmName,
                      textCapitalization: TextCapitalization.words,
                      hintText: "Enter your farm name",
                      prefixIcon: Icons.home_work_outlined,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _locationController,
                      label: "Farm Location *",
                      validator: _validateLocation,
                      textCapitalization: TextCapitalization.words,
                      hintText: "City, State/Region",
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),
                    _buildDropdownField(),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account Security",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(76, 175, 80, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password *",
                      validator: _validatePassword,
                      obscureText: !_isPasswordVisible,
                      hintText: "Create a strong password",
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password *",
                      validator: _validateConfirmPassword,
                      obscureText: !_isConfirmPasswordVisible,
                      hintText: "Re-enter your password",
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signupWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.agriculture, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Start Farming with Us",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              
            ],
          ),
        ),
      ),
    );
  }

}

