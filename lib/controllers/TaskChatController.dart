import 'dart:async';
import '../../helpers/ExportImports.dart';

class TaskChatController extends GetxController {
  final int taskId;
  TaskChatController({required this.taskId});

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final int currentUserId = 49;

  int? oldestMessageId;
  int? newestMessageId;

  bool isFetchingOlder = false;
  bool isFetchingNewer = false;

  Timer? pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchInitialMessages();
    scrollController.addListener(_onScroll);
    _startPolling();
  }

  /// ---------------- INITIAL LOAD ----------------
  Future<void> fetchInitialMessages() async {
    try {
      isLoading.value = true;

      final response = await ApiService().callApiWithMap(
        'tasks/$taskId/chat?direction=0&last_message_id=0',
        'Get',
        mapData: {},
      );

      if (response is List && response.isNotEmpty) {
        final fetched = response
            .map((e) => ChatMessage.fromJson(e, currentUserId))
            .toList();

        messages.assignAll(fetched.reversed);

        oldestMessageId = fetched.first.id;
        newestMessageId = fetched.last.id;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  /// ---------------- OLDER MESSAGES ----------------
  Future<void> fetchOlderMessages() async {
    if (isFetchingOlder || oldestMessageId == null) return;
    isFetchingOlder = true;

    try {
      final response = await ApiService().callApiWithMap(
        'tasks/$taskId/chat?direction=1&last_message_id=$oldestMessageId',
        'Get',
        mapData: {},
      );

      if (response is List && response.isNotEmpty) {
        final fetched = response
            .map((e) => ChatMessage.fromJson(e, currentUserId))
            .toList();

        oldestMessageId = fetched.first.id;

        messages.addAll(fetched.reversed);
      }
    } finally {
      isFetchingOlder = false;
    }
  }

  /// ---------------- NEWER MESSAGES ----------------
  Future<void> fetchNewerMessages() async {
    if (isFetchingNewer || newestMessageId == null) return;
    isFetchingNewer = true;

    try {
      final response = await ApiService().callApiWithMap(
        'tasks/$taskId/chat?direction=2&last_message_id=$newestMessageId',
        'Get',
        mapData: {},
      );

      if (response is List && response.isNotEmpty) {
        final fetched = response
            .map((e) => ChatMessage.fromJson(e, currentUserId))
            .toList();

        newestMessageId = fetched.last.id;

        messages.insertAll(0, fetched.reversed);
        _scrollToBottom();
      }
    } finally {
      isFetchingNewer = false;
    }
  }

  /// ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    try {
      await ApiService().callApiWithMap(
        'tasks/$taskId/chat',
        'Post',
        mapData: {"message": text},
      );

      await fetchNewerMessages();
    } catch (_) {
      Get.snackbar('Error', 'Message not sent');
    }
  }

  /// ---------------- SCROLL HANDLING ----------------
  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchOlderMessages();
    }
  }

  /// ---------------- POLLING ----------------
  void _startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchNewerMessages();
    });
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
    pollingTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
