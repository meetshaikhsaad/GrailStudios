import 'package:intl/intl.dart';

import '../../helpers/ExportImports.dart';

class TaskAssignerScreen extends StatelessWidget {
  TaskAssignerScreen({super.key});

  final ScrollController _scrollController = ScrollController();
  Future<String> _getLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final TaskAssignerController controller = Get.put(TaskAssignerController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final List<String> statusOptions = ['All', 'General', 'In Progress', 'Completed'];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchTasks(loadMore: true);
      }
    });


    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Task Assign',
        scaffoldKey: scaffoldKey,
        showBackButton: false,
      ),
      floatingActionButton: FutureBuilder<String>(
        future: _getLoggedInUserRole(), // method to read from SharedPreferences
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final loggedInRole = snapshot.data;

          // Only show FAB for admin or manager
          if (loggedInRole != 'admin' && loggedInRole != 'manager') {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: grailGold,
            onPressed: () {
              // Directly navigate to the screen
              Get.toNamed(AppRoutes.createTask);
            },
            child: const Icon(Icons.add, color: Colors.white), // FAB icon
          );
        },
      ),

      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.white,
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
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: grailGold),
                  onPressed: () {
                    // TODO: Open filter bottom sheet for status/assignee
                    Get.snackbar('Filters', 'Filter options coming soon!');
                  },
                ),
              ],
            ),
          ),

          // Filter Chips (static for now)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: statusOptions.map((status) {
                final isSelected = controller.selectedStatus.value == status ||
                    (status == 'All' && controller.selectedStatus.value.isEmpty);

                return _filterChip(status, isSelected, () {
                  if (status == 'All') {
                    controller.selectedStatus.value = '';
                  } else {
                    controller.selectedStatus.value = status;
                  }
                  controller.fetchTasks(); // fetch filtered tasks
                });
              }).toList(),
            )),
          ),

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
                  return TaskCard(task: task);
                },
              );

            }),
          ),
        ],
      ),
    );
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