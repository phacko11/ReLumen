// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'tour_list.dart';
import 'search.dart';
import 'ai_assistant.dart';
import 'guide_list.dart';
import 'user_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    ToursListScreen(),
    SearchScreen(),
    GuidesListScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color fabIconColor = const Color.fromARGB(255, 215, 62, 62); 

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
          );
        },
        shape: const CircleBorder(),
        elevation: 4.0,
        child: Padding( 
          padding: const EdgeInsets.all(0.0), 
          child: SvgPicture.asset(
            'assets/images/Union.svg', 
            semanticsLabel: 'Luminas AI Logo',
            width: 35,  
            height: 35, 
  
            placeholderBuilder: (BuildContext context) => const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white, 
              size: 28
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.antiAlias,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomAppBarItem(icon: Icons.home_filled, label: 'Tours', index: 0),
            _buildBottomAppBarItem(icon: Icons.search, label: 'Search', index: 1),
            const SizedBox(width: 40),
            _buildBottomAppBarItem(icon: Icons.people_alt_outlined, label: 'Guides', index: 2),
            _buildBottomAppBarItem(icon: Icons.person_outline, label: 'Profile', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem({required IconData icon, required String label, required int index}) {
    bool isSelected = (_selectedIndex == index);
    Color activeColor = Theme.of(context).primaryColor;
    // Lấy màu inactive từ code bạn cung cấp
    Color inactiveColor = const Color.fromARGB(255, 228, 142, 38); 

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: isSelected ? 26 : 22,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}