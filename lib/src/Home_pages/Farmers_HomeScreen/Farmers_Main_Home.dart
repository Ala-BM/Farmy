import 'package:farmy/src/Home_pages/Farmers_HomeScreen/FarmerWeather.dart';
import 'package:farmy/src/Home_pages/Farmers_HomeScreen/Farmer_HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Farmer_AddScreen.dart';

class FarmersMainHome extends StatefulWidget {
  const FarmersMainHome({super.key});

  @override
  State<FarmersMainHome> createState() => _FarmersMainHomeState();
}

class _FarmersMainHomeState extends State<FarmersMainHome> {
  int bottomNaviPageNumber = 0;
  final List<Widget> bottomNaviPages = [
    const FarmerHomescreen(),
    const FarmerAddscreen(),
    const FarmerWeather(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: bottomNaviPageNumber,
        children: bottomNaviPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus), label: "Add"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cloud), label: "Weather"),
        ],
        onTap: (value) {
          setState(() {
            bottomNaviPageNumber = value;
          });
        },
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        currentIndex: bottomNaviPageNumber,
        backgroundColor: const Color.fromRGBO(0, 178, 0, 1),
      ),
    );
  }
}
