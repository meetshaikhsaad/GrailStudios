import '../../helpers/ExportImports.dart';

class UsersRolesScreen extends StatelessWidget {
  const UsersRolesScreen({super.key});

  Future<String> _getLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  void _openAssignUserSheet(UsersAndRolesController controller) {
    controller.selectedAssignModel.value = null;
    controller.selectedAssignManager.value = null;

    controller.fetchAssignData();

    Get.bottomSheet(
      Obx(() {
        if (controller.isAssignLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Assign User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Digital Creator
              DropdownButtonFormField<UserRelation>(
                decoration: const InputDecoration(labelText: 'User'),
                value: controller.selectedAssignModel.value,
                items: controller.assignModels
                    .map((u) => DropdownMenuItem(
                  value: u,
                  child: Text(u.fullName),
                ))
                    .toList(),
                onChanged: (val) => controller.selectedAssignModel.value = val,
              ),
              const SizedBox(height: 16),

              // Manager
              DropdownButtonFormField<UserRelation>(
                decoration: const InputDecoration(labelText: 'Manager'),
                value: controller.selectedAssignManager.value ?? controller.assignManagers.first,
                items: controller.assignManagers
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.fullName),
                ))
                    .toList(),
                onChanged: (val) => controller.selectedAssignManager.value = val,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.assignUserToManager,
                      style: ElevatedButton.styleFrom(backgroundColor: grailGold),
                      child: const Text(
                        'Assign',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    final UsersAndRolesController controller = Get.put(UsersAndRolesController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Users',
        scaffoldKey: scaffoldKey
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: screensBackground,

      floatingActionButton: FutureBuilder<String>(
          future: _getLoggedInUserRole(), // method to read from SharedPreferences
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final loggedInRole = snapshot.data;

            if (loggedInRole != 'admin' && loggedInRole != 'manager') {
              return const SizedBox.shrink();; // don't show FAB
            }
          return FloatingActionButton(
            shape: CircleBorder(),
            backgroundColor: grailGold,
            onPressed: () {
              // Get.toNamed(AppRoutes.addUser);
              Get.bottomSheet(
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'User Actions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      ListTile(
                        leading: const Icon(Icons.person_add, color: grailGold, size: 28),
                        title: const Text('Add User', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          Get.back(); // Close bottom sheet
                          Get.toNamed(AppRoutes.addUser);
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.person_add_alt_1, color: grailGold, size: 28),
                        title: const Text('Assign User', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          Get.back();
                          // TODO: Implement Assign User screen/logic
                          final controller = Get.find<UsersAndRolesController>();
                          _openAssignUserSheet(controller);
                          // Example future navigation:
                          // Get.toNamed(AppRoutes.assignUser);
                        },
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        title: const Center(
                          child: Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 18)),
                        ),
                        onTap: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            },
            child: const Icon(Icons.more_horiz, color: Colors.white),
          );
        }
      ),

      body: Column(
        children: [
          // Search Bar (STATIC)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: (value) {
                controller.searchQuery.value = value.trim();
              },
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

          // Filter Chips
          FutureBuilder<String>(
            future: _getLoggedInUserRole(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final loggedInRole = snapshot.data;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // All
                    Obx(() => _filterChip(
                      'All',
                      controller.selectedRole.value.isEmpty,
                          () {
                        controller.selectedRole.value = '';
                        controller.refreshUsers();
                      },
                    )),

                    // Admins (only if logged-in user is admin)
                    if (loggedInRole == 'admin')
                      Obx(() => _filterChip(
                        'Admins',
                        controller.selectedRole.value == 'admin',
                            () {
                          controller.selectedRole.value = 'admin';
                          controller.refreshUsers();
                        },
                      )),

                    // Managers
                    if (loggedInRole == 'admin')
                    Obx(() => _filterChip(
                      'Managers',
                      controller.selectedRole.value == 'manager',
                          () {
                        controller.selectedRole.value = 'manager';
                        controller.refreshUsers();
                      },
                    )),

                    if (loggedInRole == 'admin' || loggedInRole == 'manager' )
                    Obx(() => _filterChip(
                      'Team Members',
                      controller.selectedRole.value == 'team_member',
                          () {
                        controller.selectedRole.value = 'team_member';
                        controller.refreshUsers();
                      },
                    )),

                    // Models
                    if (loggedInRole == 'admin' || loggedInRole == 'manager' || loggedInRole == 'team_member')
                    Obx(() => _filterChip(
                      'Models',
                      controller.selectedRole.value == 'digital_creator',
                          () {
                        controller.selectedRole.value = 'digital_creator';
                        controller.refreshUsers();
                      },
                    )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Users List (REACTIVE)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: grailGold),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${controller.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: controller.refreshUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.users.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return UserCard(
                    user: user,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.userDetail,
                        arguments: {
                          'userId': user.id,
                          'userFullName': user.fullName,
                        },
                      );
                    },
                  );

                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _warningText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.red, fontSize: 14),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: grailGold,
        backgroundColor: Colors.grey[300],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
        onSelected: (_) => onTap(),
      ),
    );
  }

}