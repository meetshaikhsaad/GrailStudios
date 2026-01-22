import '../../helpers/ExportImports.dart';

class TaskChatController extends GetxController {
  final int taskId;
  TaskChatController({required this.taskId});

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var messages = <ChatMessage>[].obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // Replace with your actual current user ID from auth
  final int currentUserId = 49; // Example – get from your auth service

  @override
  void onInit() {
    super.onInit();
    fetchChatMessages();
  }

  Future<void> fetchChatMessages() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await ApiService().callApiWithMap(
        'tasks/$taskId/chat',
        'Get',
        mapData: {},
      );

      if (response != null && response is List) {
        messages.value = response
            .map((json) => ChatMessage.fromJson(json, currentUserId))
            .toList()
            .reversed
            .toList(); // Latest at bottom
        _scrollToBottom();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Optimistic UI update
    final tempMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: text,
      createdAt: DateTime.now(),
      isFromCurrentUser: true,
      senderName: 'You', // or get real name
    );
    messages.insert(0, tempMsg);
    _scrollToBottom();

    messageController.clear();

    try {
      final payload = {"message": text};

      await ApiService().callApiWithMap(
        'tasks/$taskId/chat',
        'Post',
        mapData: payload,
      );

      // Refresh full chat after send
      await fetchChatMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message', backgroundColor: Colors.red);
      // Remove temp message on failure
      messages.removeWhere((m) => m.id == tempMsg.id);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}