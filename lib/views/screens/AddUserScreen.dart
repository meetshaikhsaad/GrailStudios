import '../../helpers/ExportImports.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddUserController controller = Get.put(AddUserController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Add User',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 40, 35, 40),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/images/add_user.png",
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Full Name
              TextFormField(
                controller: controller.fullNameController,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Username
              TextFormField(
                controller: controller.usernameController,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'johndoe123',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'johndoe@gmail.com',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role
              Obx(() {
                // filter roles based on logged-in role
                final visibleRoles = controller.roleOptions.where((role) {
                  if (role['id'] == 'admin' || role['id'] == 'manager') {
                    return controller.loggedInRole.value == 'admin';
                  }
                  return true;
                }).toList();

                return DropdownButtonFormField<String>(
                  value: controller.selectedRole.value.isEmpty
                      ? null
                      : controller.selectedRole.value,
                  hint: const Text('Select Role'),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: visibleRoles.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['id'] as String,
                      child: Text(option['orientationName'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedRole.value = value!;
                    controller.selectedManagerId.value = 0;
                    controller.selectedDigitalCreatorIds.clear();
                  },
                  validator: (value) =>
                  value == null ? 'Please select a role' : null,
                );
              }),

              const SizedBox(height: 20),

              // Manager Dropdown (only show if role is team_member or digital_creator)
              Obx(() => Visibility(
                visible: controller.selectedRole.value == 'digital_creator',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Obx(() {
                    if (controller.isLoadingManagers.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // manager
                    return DropdownButtonFormField<int>(
                      value: controller.selectedManagerId.value,
                      hint: const Text('Select Manager'),
                      decoration: InputDecoration(
                        labelText: 'Manager',
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: controller.managers.map((manager) {
                        return DropdownMenuItem<int>(
                          value: manager.id,
                          child: Text(manager.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedManagerId.value = value;
                      },
                    );
                  }),
                ),
              )),

              // Multi-select Digital Creators (only for Manager role)
              Obx(() => Visibility(
                visible: controller.selectedRole.value == 'manager',
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assign Models',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (controller.isLoadingDigitalCreators.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.digitalCreators.isEmpty) {
                          return const Text('No digital creators available', style: TextStyle(color: Colors.grey));
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.digitalCreators.map((creator) {
                            final isSelected = controller.selectedDigitalCreatorIds.contains(creator.id);
                            return FilterChip(
                              label: Text(creator.fullName),
                              selected: isSelected,
                              backgroundColor: Colors.grey[200],
                              selectedColor: grailGold,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                              onSelected: (selected) {
                                if (selected) {
                                  controller.selectedDigitalCreatorIds.add(creator.id);
                                } else {
                                  controller.selectedDigitalCreatorIds.remove(creator.id);
                                }
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              )),

              // Phone
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: '+1234567890',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
                hint: const Text('Select Gender'),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: controller.genders
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => controller.selectedGender.value = value!,
                validator: (value) => value == null ? 'Please select gender' : null,
              )),
              const SizedBox(height: 20),

              // Bio (Multiline)
              TextFormField(
                controller: controller.bioController,
                maxLines: 4,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself...',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),

              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Min 8 characters',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Retype Password
              TextFormField(
                controller: controller.retypePasswordController,
                obscureText: true,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Retype Password',
                  hintText: 'Confirm your password',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please retype password';
                  }
                  if (value != controller.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),

              // Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      controller.saveUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grailGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Save User',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}