import 'dart:convert';

import 'package:farmy/ApiKey.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/weather_pages/CloudsDay.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/weather_pages/Rainyday.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/weather_pages/SunnyDay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ApiModels/Apimodel.dart';
import 'ApiModels/GetLocation.dart';

class FarmerWeather extends StatefulWidget {
  const FarmerWeather({super.key});

  @override
  State<FarmerWeather> createState() => _FarmerWeatherState();
}

class _FarmerWeatherState extends State<FarmerWeather> {
  static const List<Widget> _weatherPages = [
    SunnyDay(),
    Rainyday(),
    CloudsDay()
  ];

  static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  static const Color _cardBackground = Colors.white10;
  
  ApiModel? _apiData;
  List<String> _weatherDetails = [];
  int _currentPageIndex = 0;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initializeWeatherData();
  }

  Future<void> _initializeWeatherData() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await GetLocation.getCurrentCordinartes();
      _latitude = position.latitude;
      _longitude = position.longitude;
      
      debugPrint('Location acquired - Latitude: $_latitude, Longitude: $_longitude');
      
      await _fetchWeatherData();
    } catch (error) {
      debugPrint('Error getting location: $error');
      _showErrorSnackBar('Failed to get location. Please check permissions.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_latitude == null || _longitude == null) {
      debugPrint('Coordinates not available');
      return;
    }

    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$_latitude&lon=$_longitude'
        '&appid=${ApiKey.weatherApiKey}&units=metric'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _apiData = ApiModel.fromMap(data);
          _updateWeatherDisplay();
        });
      } else {
        throw Exception('Weather API request failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching weather data: $error');
      _showErrorSnackBar('Failed to fetch weather data. Please try again.');
    }
  }

  void _updateWeatherDisplay() {
    if (_apiData == null) return;

    _currentPageIndex = _getWeatherPageIndex(_apiData!.weatherMain);

    _weatherDetails = [
      'Latitude: $_latitude',
      'Longitude: $_longitude',
      'Temperature: ${_apiData!.temp}°C',
      'Humidity: ${_apiData!.humidity}%',
      'Pressure: ${_apiData!.pressure} hPa',
      'Wind Speed: ${_apiData!.windSpeed} m/s',
      'Description: ${_apiData!.weatherDescription}',
    ];
  }

  int _getWeatherPageIndex(String? weatherMain) {
    if (weatherMain == null) return 0;
    
    switch (weatherMain.toLowerCase()) {
      case 'clouds':
        return 2;
      case 'rain':
        return 1;
      default:
        return 0;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.person, color: Colors.white),
          tooltip: 'Open menu',
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      elevation: 11,
      shadowColor: Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 20),
          _buildWeatherDetailsList(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.location_solid,
              color: _primaryGreen,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              _apiData?.cityName ?? 'Unknown Location',
              style: const TextStyle(
                color: _primaryGreen,
                fontFamily: "Poppins-SemiBold",
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsList() {
    if (_weatherDetails.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No weather data available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _weatherDetails.length,
        itemBuilder: (context, index) => ListTile(
          dense: true,
          title: Text(
            _weatherDetails[index],
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Poppins-SemiBold",
              fontSize: 14,
            ),
          ),
        ),
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white54,
          thickness: 0.5,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(
          color: _primaryGreen,
          radius: 20,
        ),
      );
    }

    return Column(
      children: [
        _buildWeatherDisplay(),
        _buildWeatherInfoCard(),
      ],
    );
  }

  Widget _buildWeatherDisplay() {
    return SizedBox(
      height: 470,
      width: double.infinity,
      child: _weatherPages[_currentPageIndex],
    );
  }

  Widget _buildWeatherInfoCard() {
    return Container(
      height: 220,
      width: 375,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 15,
        shadowColor: Colors.white10,
        color: _cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTemperatureAndWeatherRow(),
              _buildLocationRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureAndWeatherRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoColumn(
          "Temperature",
          "${_apiData?.temp ?? '--'}°C",
        ),
        _buildInfoColumn(
          "Weather",
          _apiData?.weatherMain ?? 'Unknown',
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_solid,
              color: Color.fromARGB(255, 51, 0, 255),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Current Location",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Poppins_light",
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _apiData?.cityName ?? 'Unknown',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: "Poppins-SemiBold",
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: "Poppins_light",
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}