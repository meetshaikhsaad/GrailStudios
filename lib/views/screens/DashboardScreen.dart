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

      drawer: AppBarWidget.appDrawer(_scaffoldKey),

      body: _pages[_selectedIndex],

      bottomNavigationBar: AppBarWidget.appBottomNav(_selectedIndex, _onItemTapped),
    );
  }
}

