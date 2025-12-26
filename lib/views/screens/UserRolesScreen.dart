import 'dart:ui';
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
        title: 'Users & Roles',
        scaffoldKey: scaffoldKey
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      body: Column(
        children: [
          // Search Bar (STATIC)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', true, () {}),
                // _filterChip('Managers 12', false, () {}),
                // _filterChip('Models 40', false, () {}),
                // _filterChip('Team 112', false, () {}),
              ],
            ),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 32,
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role,
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          // const SizedBox(height: 10),
                          // _warningText('Tasks: 7/12 (5 missed tasks)'),
                          // _warningText('Missing items - 8'),
                          // const SizedBox(height: 4),
                          // _warningText('NDA - Expired'),
                          // _warningText('Content - Pending'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                      onTap: () {
                        // Navigate to user detail
                        // Get.to(() => UserDetailScreen(user: user));
                      },
                    ),
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