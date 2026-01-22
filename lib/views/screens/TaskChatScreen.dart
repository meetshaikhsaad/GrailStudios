import '../../helpers/ExportImports.dart';

class TaskChatScreen extends StatelessWidget {
  final int taskId;
  TaskChatScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: "Chat",
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.white,
      body: Obx(() {
        return Text("data");
      }),
    );
  }
}