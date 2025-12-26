import 'dart:ui';
import 'package:flutter/material.dart';
import '../../helpers/ExportImports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Placeholder pages for bottom nav (you can replace later)
  static const List<Widget> _pages = [
    Center(child: Text('Home Content', style: TextStyle(fontSize: 24))),
    Center(child: Text('Tasks Content', style: TextStyle(fontSize: 24))),
    Center(child: Text('Content Vault', style: TextStyle(fontSize: 24))),
    Center(child: Text('Compliance Content', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: ClipPath(
          clipper: AppBarWaveClipper(),
          child: AppBar(
            backgroundColor: grailGold,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              _selectedIndex == 0 ? 'Dashboard' : ['Tasks', 'Content', 'Compliance'][_selectedIndex - 1],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    onPressed: () {
                      // Notification action
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3', // Example badge
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),

      drawer: _buildDrawer(),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: grailGold,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open_outlined),
            activeIcon: Icon(Icons.folder_open),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Compliance',
          ),
        ],
      ),
    );
  }

  // Drawer matching your first screenshot
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: grailGold),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/logo_without_text.png',
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Grail Studios',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Admin Portal',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'Home', 0),
          _drawerItem(Icons.people, 'Users & Roles', 1),
          _drawerItem(Icons.assignment, 'Tasks', 2),
          _drawerItem(Icons.folder, 'Content Vault', 3),
          _drawerItem(Icons.verified, 'Compliance', 4),
          _drawerItem(Icons.bar_chart, 'Reports', 5),
          _drawerItem(Icons.settings, 'Settings', 6),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? grailGold : Colors.grey),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedTileColor: grailGold.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _scaffoldKey.currentState?.closeDrawer();
      },
    );
  }
}

class AppBarWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double r = (size.width * 0.09).clamp(28.0, 80.0);

    final path = Path();

    // Top-left to top-right (full top edge)
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    //
    // // Bottom-right inverted corner (concave — creates rise on right)
    path.lineTo(size.width, size.height-(r*2));
    path.arcToPoint(
      Offset(size.width - r, size.height-(r)),
      radius: Radius.circular(r),
      clockwise: true, // Inverted curve
    );
    //
    // // Straight across bottom to left
    path.lineTo(r, size.height - r);
    //
    // // Bottom-left normal convex corner
    path.arcToPoint(
      Offset(0, size.height),
      radius: Radius.circular(r),
      clockwise: false,
    );
    //
    // // Back to start
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}