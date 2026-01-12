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
        showBackButton: Get.arguments['showBackButton'] != null
            ? Get.arguments['showBackButton']
            : true,
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
                child: GestureDetector(
                  onTap: controller.pickProfilePicture,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      Obx(() => controller.isUploadingImage.value
                          ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      )
                          : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: grailGold, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      )),
                    ],
                  ),
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

              if (user.role == 'digital_creator') ...[
                Obx(() {
                  // Ensure selectedManager is an instance from the managers list
                  UserRelation? dropdownValue;
                  if (controller.selectedManager.value != null) {
                    dropdownValue = controller.managers.firstWhere(
                          (m) => m.id == controller.selectedManager.value!.id,
                      orElse: () => controller.managers[0],
                    );
                  } else if (user.manager != null) {
                    // Preselect user's current manager
                    dropdownValue = controller.managers.firstWhere(
                          (m) => m.id == user.manager!.id,
                      orElse: () => controller.managers[0],
                    );
                    controller.selectedManager.value = dropdownValue;
                  }

                  return DropdownButtonFormField<UserRelation>(
                    value: dropdownValue == null? controller.managers[0] : dropdownValue,
                    hint: const Text('Select Manager'),
                    decoration: _inputDecoration('Manager'),
                    items: controller.managers.map((manager) {
                      return DropdownMenuItem<UserRelation>(
                        value: manager,
                        child: Text(manager.fullName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.selectedManager.value = value;
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],

              if (user.role == 'manager') ...[
                const Text('Assigned Models', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.availableModels.isEmpty) {
                    return const Text('No digital creators available', style: TextStyle(color: Colors.grey));
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.availableModels.map((model) {
                      final isSelected = controller.selectedModels.any((m) => m.id == model.id);
                      return FilterChip(
                        label: Text(model.fullName),
                        selected: isSelected,
                        backgroundColor: Colors.grey[200],
                        selectedColor: grailGold,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedModels.add(model);
                          } else {
                            controller.selectedModels.removeWhere((m) => m.id == model.id);
                          }
                        },
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 24),
              ],

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
                  if(Get.arguments['showDeleteButton'] != null
                      ? Get.arguments['showDeleteButton']
                      : true)
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
                  if(Get.arguments['showDeleteButton'] != null
                      ? Get.arguments['showDeleteButton']
                      : true)
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