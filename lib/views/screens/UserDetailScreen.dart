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
        title: Get.arguments['userFullName'],
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
          return Center(child: Text('Error: ${controller.errorMessage.value}'));
        }

        final user = controller.user.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(user.profilePictureUrl!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 30),

              // Uneditable: Name
              _infoCard(Icons.person, 'Name', user.fullName, editable: false),

              const SizedBox(height: 16),

              // Uneditable: Email
              _infoCard(Icons.email, 'Email', user.email, editable: false),

              const SizedBox(height: 16),

              // Role
              _infoCard(Icons.verified_user, 'Role', _capitalize(user.role), editable: false),

              const SizedBox(height: 30),

              // Editable Fields
              TextField(
                controller: controller.phoneController,
                decoration: _inputDecoration('Phone'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.bioController,
                maxLines: 4,
                decoration: _inputDecoration('Bio'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.address1Controller,
                decoration: _inputDecoration('Address Line 1'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.cityController,
                decoration: _inputDecoration('City'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.zipcodeController,
                decoration: _inputDecoration('ZIP Code'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.xLinkController,
                decoration: _inputDecoration('X (Twitter) Link'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.ofLinkController,
                decoration: _inputDecoration('OnlyFans Link'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller.instaLinkController,
                decoration: _inputDecoration('Instagram Link'),
              ),
              const SizedBox(height: 40),

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
                      onPressed: controller.updateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: grailGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Update User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _infoCard(IconData icon, String label, String value, {bool editable = true}) {
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