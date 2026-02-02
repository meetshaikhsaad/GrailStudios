import '../../helpers/ExportImports.dart';

class TaskSubmissionScreen extends StatelessWidget {
  TaskSubmissionScreen({super.key});

  final ScrollController _scrollController = ScrollController();
  Future<String> _getLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final TaskSubmissionController controller = Get.put(TaskSubmissionController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final List<Map<String, String>> statusOptions = [
      {'label': 'All', 'value': ''},           // All → empty string
      {'label': 'To Do', 'value': 'To Do'},
      {'label': 'Blocked', 'value': 'Blocked'},
      {'label': 'Completed', 'value': 'Completed'},
      {'label': 'Missed', 'value': 'Missed'},
    ];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchTasks(loadMore: true);
      }
    });


    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Task Submit',
        scaffoldKey: scaffoldKey,
        showBackButton: false,
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: screensBackground,
      body: Column(
        children: [
          // Search Bar + Filter Icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                // const SizedBox(width: 12),
                // IconButton(
                //   icon: const Icon(Icons.filter_list, color: grailGold),
                //   onPressed: () {
                //     // TODO: Open filter bottom sheet for status/assignee
                //     Get.snackbar('Filters', 'Filter options coming soon!');
                //   },
                // ),
              ],
            ),
          ),

          Obx(() => HorizontalFilterChips(
            options: statusOptions,
            selectedValue: controller.selectedStatus.value,
            onSelectionChanged: (val) {
              controller.selectedStatus.value = val; // '' for All
              controller.fetchTasks(); // fetch filtered tasks
            },
          )),

          const SizedBox(height: 16),

          // Tasks List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: grailGold));
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${controller.errorMessage.value}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.tasks.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.tasks.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.tasks.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: grailGold),
                      ),
                    );
                  }

                  final task = controller.tasks[index];
                  return InkWell(
                    onTap: () => _showTaskDetailsBottomSheet(task),
                    onLongPress: () => _showTaskOptionsBottomSheet(task),
                    child: TaskCard(task: task),
                  );
                },
              );

            }),
          ),
        ],
      ),
    );
  }

  void _showTaskOptionsBottomSheet(Task task) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Task Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Visibility(
                visible:task.status.toLowerCase() == 'to do',
                child: const SizedBox(height: 20),),
              Visibility(
                visible: task.status.toLowerCase() == 'to do',
                child: ListTile(
                  leading: const Icon(Icons.edit, color: grailGold),
                  title: const Text('Submit Work'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close sheet
                    // Navigation AFTER sheet is closed
                    Future.microtask(() {
                      Get.to(() => TaskSubmissionUploadScreen(taskId: task.id!));
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Chat Option
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.blue),
                title: const Text('Chat'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.microtask(() {
                    Get.to(() => TaskChatScreen(taskId: task.id!));
                  });
                },
              ),

              const SizedBox(height: 10),

              // Cancel
              ListTile(
                title: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteTask(int taskId) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this task?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // close dialog
        try {
          await ApiService().callApiWithMap(
            'tasks/$taskId',
            'DELETE',
            mapData: {},
          );
          Get.snackbar('Success', 'Task deleted successfully');
          // Refresh task list
          final controller = Get.find<TaskAssignerController>();
          controller.fetchTasks();
        } catch (e) {
          Get.snackbar('Error', 'Failed to delete task: $e', backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  void _showTaskDetailsBottomSheet(Task task) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Center(
                            child: Text(
                              task.title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            task.description ?? 'No description provided.',
                            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 20),

                          // Tags/Chips Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statusChip(task.priority ?? 'Medium', Colors.red),
                              _statusChip(task.context ?? 'General', Colors.blue),
                              _statusChip(task.status, _getStatusColor(task.status)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Assignee
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: task.assignee.profilePictureUrl != null
                                    ? NetworkImage(task.assignee.profilePictureUrl!)
                                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.assignee.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  Text(
                                    'Assigned by ${task.assigner.fullName}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Today, 08:25 PM', // Replace with real time if available
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 24),

                          // Blocked Reason (if Blocked)
                          if (task.status.toLowerCase() == 'blocked') ...[
                            const Text(
                              'Blocked Reason',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Blocked: Waiting for model to send final approval...',
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Attachments Section
                          if (task.attachments.isNotEmpty) ...[
                            const Text(
                              'Attachments',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            ...task.attachments.map((attachment) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file, color: grailGold),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attachment.fileUrl.split('/').last,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Uploaded Jan 2025', // Format real date
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye, color: grailGold),
                                      onPressed: () {
                                        _showAttachmentPreview(attachment.fileUrl);
                                        // TODO: Download file
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.download, color: Colors.red),
                                      onPressed: () async {
                                        await _downloadAttachment(attachment.fileUrl);
                                        // TODO: Delete attachment
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],

                          const SizedBox(height: 30),
                          Visibility(
                            visible: task.status.toLowerCase() == 'to do',
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: grailGold,
                                minimumSize: const Size.fromHeight(45),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text('Submit Work', style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Future.microtask(() {
                                  Get.to(() => TaskSubmissionUploadScreen(taskId: task.id!));
                                });
                              },
                            ),
                          ),
                          Visibility(
                            visible:task.status.toLowerCase() == 'to do',
                            child: const SizedBox(height: 10),),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: grailGold,
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            icon: const Icon(Icons.chat, color: Colors.white),
                            label: const Text('Open Chat', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Future.microtask(() {
                                Get.to(() => TaskChatScreen(taskId: task.id!));
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Show full image preview in bottom sheet
  void _showAttachmentPreview(String imageUrl) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: grailGold));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error, color: Colors.red, size: 60));
                    },
                  ),
                ),
              ),
              // Download Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grailGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _downloadAttachment(imageUrl);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadAttachment(String url, {BuildContext? context}) async {
    try {
      final fileName = url.split('/').last;

      // Use the DownloadService
      await DownloadService.instance.downloadFile(
        url,
        fileName,
        context: context,
      );
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
      print("Download failed: $e");
    }
  }



// Helper for status chips
  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

// Helper to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.blue;
      case 'blocked':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }


  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: grailGold,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide.none),
        onSelected: (_) => onTap(),
      ),
    );
  }
}