import 'package:flutter/material.dart';
import 'package:flutter_fitness_app/pages/food.dart';
import 'package:flutter_fitness_app/pages/measure.dart';
import 'package:flutter_fitness_app/pages/profile.dart';
import 'package:flutter_fitness_app/pages/settings.dart';
import 'package:flutter_fitness_app/pages/workout.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 2;
  static final List<Widget> _widgetOptions = <Widget>[
    const History(),
    Workout(),
    const Profile(),
    const Food(),
    const Measure(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, color: Colors.red[800]),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center, color: Colors.red[800]),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.red[800]),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal, color: Colors.red[800]),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.red[800]),
            label: 'Measure',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
