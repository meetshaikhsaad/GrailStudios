import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class TaskChatScreen extends StatelessWidget {
  final int taskId;
  const TaskChatScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskChatController(taskId: taskId));
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBarWidget.appBarWave(
        title: 'Chat',
        showBackButton: true,
        notificationVisibility: false,
        scaffoldKey: scaffoldKey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                reverse: true,
                controller: controller.scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (_, index) {
                  final msg = controller.messages[index];
                  final isMe = msg.isFromCurrentUser;

                  return Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: isMe ? 60 : 0,
                          right: isMe ? 0 : 60,
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? grailGold : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
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
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                          child: Text(
                            DateFormat('hh:mm a').format(msg.createdAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1)
                    ],
                  );
                },
              );
            }),
          ),

          /// INPUT BAR
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: grailGold),
                  onPressed: controller.sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
