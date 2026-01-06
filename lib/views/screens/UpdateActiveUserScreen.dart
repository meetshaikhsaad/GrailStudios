import '../../helpers/ExportImports.dart';

class ActiveUserScreen extends StatelessWidget {
  final String userId;

  ActiveUserScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active User Screen'),
      ),
      body: Center(
        child: Text('User ID: $userId'),
      ),
    );
  }
}