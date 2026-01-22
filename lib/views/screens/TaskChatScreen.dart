import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class TaskChatScreen extends StatelessWidget {
  final int taskId;

  const TaskChatScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final TaskChatController controller = Get.put(TaskChatController(taskId: taskId));
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Chat',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: grailGold));
              }
              if (controller.hasError.value) {
                return Center(child: Text('Error: ${controller.errorMessage.value}'));
              }
              if (controller.messages.isEmpty) {
                return const Center(child: Text('No messages yet. Start the conversation!'));
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final showDate = index == controller.messages.length - 1 ||
                      DateFormat('dd MMM yyyy').format(msg.createdAt) !=
                          DateFormat('dd MMM yyyy').format(controller.messages[index + 1].createdAt);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDate)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              DateFormat('dd MMM yyyy').format(msg.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ),

                      Align(
                        alignment: msg.isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: msg.isFromCurrentUser ? 60 : 0,
                            right: msg.isFromCurrentUser ? 0 : 60,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isFromCurrentUser ? grailGold : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: msg.isFromCurrentUser ? const Radius.circular(20) : Radius.zero,
                              bottomRight: msg.isFromCurrentUser ? Radius.zero : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.message,
                            style: TextStyle(
                              color: msg.isFromCurrentUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      // Time
                      Align(
                        alignment: msg.isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                          child: Text(
                            DateFormat('hh:mm a').format(msg.createdAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: controller.messageController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: grailGold, size: 28),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}