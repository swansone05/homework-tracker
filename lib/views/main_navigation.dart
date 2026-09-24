import 'package:flutter/material.dart';

import '../home_screen.dart';
import 'assignment_list_screen.dart';
import 'course_list_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AssignmentListScreen(),
    const CourseListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
                  ? 'Assignments'
                  : _selectedIndex == 2
                      ? 'Courses'
                      : 'Profile',
        ),
      ),
      body: _screens[_selectedIndex],

      // Bottom navigation with a black space underneath.
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          color: Colors.white,
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Assignments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}