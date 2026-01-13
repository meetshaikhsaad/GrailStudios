import '../../helpers/ExportImports.dart';

class AppBarWidget {
  // Reusable Drawer
  static Widget appDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    return FutureBuilder<ActiveUser?>(
      future: ApiService.getSavedUser(),
      builder: (context, snapshot) {
        final user = snapshot.data?.user;

        return Drawer(
          backgroundColor: const Color(0xFFF7F7F7),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                decoration: BoxDecoration(
                  color: grailGold,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: GestureDetector(
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                  },
                  child: Row(
                    spacing: 25,
                    children: [
                      const Icon(Icons.menu, color: Colors.white, size: 25),
                      const Text(
                        'Menu',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= PROFILE CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Admin User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                user?.role ?? 'ADMIN',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF3A7AFE), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: Colors.green),
                        onPressed: () {
                          scaffoldKey.currentState?.closeDrawer();
                          // Get.toNamed(AppRoutes.profile);
                          print("userid: "+user!.id.toString());
                          Get.offAllNamed(
                            AppRoutes.userDetail,
                            arguments: {
                              'userId': user?.id,
                              'userFullName': user?.fullName,
                              'showBackButton': false,
                              'showDeleteButton': false,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= MENU =================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _drawerItem(Icons.home_outlined, 'Dashboard', AppRoutes.dashboard, scaffoldKey),
                    if (user?.role == 'admin' || user?.role == 'manager')
                      _drawerItem(Icons.people_outline, 'Users', AppRoutes.usersRoles, scaffoldKey),
                    if (user?.role == 'manager' || user?.role == 'team_member')
                      _drawerItem(Icons.assignment_outlined, 'Task Assigner', AppRoutes.tasksAssigner, scaffoldKey),
                    if (user?.role == 'digital_Creator' )
                      _drawerItem(Icons.assignment_outlined, 'Task Submission', AppRoutes.tasksSubmission, scaffoldKey),
                    _drawerItem(Icons.folder_open_outlined, 'Content Vault', AppRoutes.contentVault, scaffoldKey),
                    _drawerItem(Icons.verified_user_outlined, 'Compliance', AppRoutes.compliance, scaffoldKey),
                    _drawerItem(Icons.bar_chart_outlined, 'Reports', AppRoutes.reports, scaffoldKey),
                    ExpansionTile(
                      leading: const Icon(Icons.settings_outlined, color: Colors.grey),
                      title: const Text(
                        'Settings',
                        // style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      childrenPadding: const EdgeInsets.only(left: 16),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, size: 20),
                          title: const Text('Profile'),
                          onTap: () {
                            scaffoldKey.currentState?.closeDrawer();
                            Get.offAllNamed(
                              AppRoutes.userDetail,
                              arguments: {
                                'userId': user?.id,
                                'userFullName': user?.fullName,
                                'showBackButton': false,
                                'showDeleteButton': false,
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock_reset_outlined, size: 20),
                          title: const Text('Reset Password'),
                          onTap: () {
                            scaffoldKey.currentState?.closeDrawer();
                            Get.offAllNamed(
                              AppRoutes.resetPassword,
                              arguments: {
                                'userId': user?.id,
                                'userFullName': user?.fullName,
                              },);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= BOTTOM =================
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    _drawerItem(Icons.info_outline, 'About App', AppRoutes.settings, scaffoldKey),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        scaffoldKey.currentState?.closeDrawer();
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () async {
                                  Get.back();
                                  await ApiService.clearUserData();
                                  Get.offAllNamed(AppRoutes.login);
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), activeIcon: Icon(Icons.folder_open), label: 'Content'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Compliance'),
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
          automaticallyImplyLeading: false,
          // Important: prevents default back button
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
                        child: Text(notificationCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
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
    path.lineTo(size.width, size.height - (r * 2));
    path.arcToPoint(
      Offset(size.width - r, size.height - (r)),
      radius: Radius.circular(r),
      clockwise: true, // Inverted curve
    );

    // Straight across bottom to left
    path.lineTo(r, size.height - r);

    // Bottom-left normal convex corner
    path.arcToPoint(Offset(0, size.height), radius: Radius.circular(r), clockwise: false);

    // Back to start
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
