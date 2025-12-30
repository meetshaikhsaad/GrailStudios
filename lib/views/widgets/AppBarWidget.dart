import '../../helpers/ExportImports.dart';

class AppBarWidget {
  // Reusable Drawer
  static Widget appDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
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
          _drawerItem(Icons.home, 'Home', AppRoutes.dashboard, scaffoldKey),
          _drawerItem(Icons.people, 'Users & Roles', AppRoutes.usersRoles, scaffoldKey),
          _drawerItem(Icons.assignment, 'Tasks', AppRoutes.tasks, scaffoldKey),
          _drawerItem(Icons.folder, 'Content Vault', AppRoutes.contentVault, scaffoldKey),
          _drawerItem(Icons.verified, 'Compliance', AppRoutes.compliance, scaffoldKey),
          _drawerItem(Icons.bar_chart, 'Reports', AppRoutes.reports, scaffoldKey),
          _drawerItem(Icons.settings, 'Settings', AppRoutes.settings, scaffoldKey),
        ],
      ),
    );
  }

  static Widget _drawerItem(IconData icon, String title, String routeName, GlobalKey<ScaffoldState> scaffoldKey) {
    bool isSelected = Get.currentRoute == routeName;

    return ListTile(
      leading: Icon(icon, color: isSelected ? grailGold : Colors.grey),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: grailGold.withOpacity(0.1),
      onTap: () {
        scaffoldKey.currentState?.closeDrawer();
        if (Get.currentRoute != routeName) {
          Get.offAllNamed(routeName);
        }
      },
    );
  }

  // Reusable Bottom Navigation Bar
  static Widget appBottomNav(int currentIndex, ValueChanged<int> onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: grailGold,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
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
    );
  }

  static PreferredSizeWidget appBarWave({
    required String title,
    required GlobalKey<ScaffoldState> scaffoldKey,
    int notificationCount = 3,
    bool notificationVisibility = true,
    bool showBackButton = false, // ← New parameter
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: ClipPath(
        clipper: AppBarWaveClipper(),
        child: AppBar(
          backgroundColor: grailGold,
          elevation: 0,
          automaticallyImplyLeading: false, // Important: prevents default back button
          leading: showBackButton
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
          )
              : IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          actions: [
            if (notificationVisibility)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            if (notificationVisibility) const SizedBox(width: 10),
          ],
        ),
      ),
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

    // Bottom-right inverted corner (concave — creates rise on right)
    path.lineTo(size.width, size.height-(r*2));
    path.arcToPoint(
      Offset(size.width - r, size.height-(r)),
      radius: Radius.circular(r),
      clockwise: true, // Inverted curve
    );

    // Straight across bottom to left
    path.lineTo(r, size.height - r);

    // Bottom-left normal convex corner
    path.arcToPoint(
      Offset(0, size.height),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // Back to start
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}