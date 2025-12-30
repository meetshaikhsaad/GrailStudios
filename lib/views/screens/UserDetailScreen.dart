import '../../helpers/ExportImports.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserDetailController controller = Get.put(UserDetailController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: Get.arguments['userFullName'], // Safe fallback
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
          showBackButton: true,
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: grailGold));
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${controller.errorMessage.value}'),
                ElevatedButton(onPressed: controller.fetchUserDetail, child: const Text('Retry')),
              ],
            ),
          );
        }

        final user = controller.user.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  // backgroundColor: Colors.transparent,
                  radius: 60,
                  backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(user.profilePictureUrl!)
                      : const AssetImage('assets/images/splash_person1.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 30),

              _infoCard(Icons.person, 'Name', user.fullName),
              const SizedBox(height: 16),
              _infoCard(Icons.email, 'Email', user.email),
              const SizedBox(height: 16),
              _infoCard(Icons.verified_user, 'Role', _capitalize(user.role)),

              const SizedBox(height: 30),

              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.red[50],
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(color: Colors.red[200]!),
              //   ),
              //   child: const Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Tasks: 7/12 (5 missed tasks)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              //       SizedBox(height: 8),
              //       Text('NDA - Expired', style: TextStyle(color: Colors.red)),
              //       SizedBox(height: 8),
              //       Text('Content - Pending', style: TextStyle(color: Colors.red)),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 50),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.deleteUser,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Delete User', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Get.to(() => EditUserScreen(user: user));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: grailGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Edit User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}