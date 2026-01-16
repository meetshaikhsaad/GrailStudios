import '../../helpers/ExportImports.dart';

class TaskSubmissionScreen extends StatelessWidget {
  const TaskSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBarWidget.appBarWave(
            title: 'Task Submission',
            scaffoldKey: scaffoldKey
        ),
      body: Center(
        child: Text('This is the Task Submission Screen'),)
    );
  }

}