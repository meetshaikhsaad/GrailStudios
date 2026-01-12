import '../../helpers/ExportImports.dart';

class UsersRolesScreen extends StatelessWidget {
  const UsersRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersAndRolesController controller = Get.put(UsersAndRolesController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Users & Assign Users',
        scaffoldKey: scaffoldKey
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),

      floatingActionButton: FloatingActionButton(
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
                      Get.snackbar(
                        'Coming Soon',
                        'Assign User feature will be available soon!',
                        backgroundColor: grailGold,
                        colorText: Colors.white,
                      );
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

          // Filter Chips (STATIC)
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip(
                    'All',
                    controller.selectedRole.value.isEmpty,
                        () {
                      controller.selectedRole.value = '';
                      controller.refreshUsers();
                    },
                  ),
                  _filterChip(
                    'Admins',
                    controller.selectedRole.value == 'admin',
                        () {
                      controller.selectedRole.value = 'admin';
                      controller.refreshUsers();
                    },
                  ),
                  _filterChip(
                    'Managers',
                    controller.selectedRole.value == 'manager',
                        () {
                      controller.selectedRole.value = 'manager';
                      controller.refreshUsers();
                    },
                  ),
                  _filterChip(
                    'Models',
                    controller.selectedRole.value == 'digital_creator',
                        () {
                      controller.selectedRole.value = 'digital_creator';
                      controller.refreshUsers();
                    },
                  ),
                ],
              ),
            );
          }),


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
                      print("userid: " + user.id.toString());
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
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide.none,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

}