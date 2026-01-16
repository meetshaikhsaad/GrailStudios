import '../../helpers/ExportImports.dart';

class TaskAssignerScreen extends StatelessWidget {
  const TaskAssignerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBarWidget.appBarWave(
            title: 'Task Assigner',
            scaffoldKey: scaffoldKey
        ),
      body: Center(
        child: Text('This is the Task Assigner Screen'),)
    );
  }

}