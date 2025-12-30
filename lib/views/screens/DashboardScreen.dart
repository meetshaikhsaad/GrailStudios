import '../../helpers/ExportImports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

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
      appBar: AppBarWidget.appBarWave(
        title: _selectedIndex == 0 ? 'Dashboard' : ['Tasks', 'Content', 'Compliance'][_selectedIndex - 1],
        scaffoldKey: _scaffoldKey,
      ),
      drawer: AppBarWidget.appDrawer(_scaffoldKey),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBarWidget.appBottomNav(_selectedIndex, _onItemTapped),
    );
  }
}

