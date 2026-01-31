import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureAssignerScreen extends StatelessWidget {
  SignatureAssignerScreen({super.key});

  final ScrollController _scrollController = ScrollController();
  final List<String> statusOptions = ['All', 'Pending', 'Signed', 'Expired'];

  Future<String> _getLoggedInUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.USER_ROLE) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignatureAssignerController());
    final scaffoldKey = GlobalKey<ScaffoldState>();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchSignatures(loadMore: true);
      }
    });

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Signature Assign',
        scaffoldKey: scaffoldKey,
        showBackButton: false,
      ),

      // ✅ FAB (same conditions as TaskAssigner)
      floatingActionButton: FutureBuilder<String>(
        future: _getLoggedInUserRole(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final role = snapshot.data;
          if (role != 'admin' && role != 'manager') {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: grailGold,
            onPressed: () {
              Get.toNamed(AppRoutes.signatureAdd); // adjust route if needed
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),

      drawer: AppBarWidget.appDrawer(scaffoldKey),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search signatures',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Status Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: statusOptions.map((status) {
                final isSelected =
                    controller.selectedStatus.value == status ||
                        (status == 'All' &&
                            controller.selectedStatus.value.isEmpty);

                return _filterChip(status, isSelected, () {
                  controller.onStatusChanged(
                    status == 'All' ? '' : status,
                  );
                });
              }).toList(),
            )),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: grailGold),
                );
              }

              if (controller.signatures.isEmpty) {
                return const Center(child: Text('No signatures found'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.signatures.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.signatures.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: grailGold),
                      ),
                    );
                  }

                  final signature = controller.signatures[index];
                  return InkWell(
                    onTap: () => _viewSignature(signature),
                    onLongPress: () => _showSignatureOptions(signature),
                    child: SignatureCard(signature: signature),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  void _viewSignature(Signature signature) {
    // Navigate to details / preview screen
    Future.microtask(() {
      Get.to(() => SignatureViewScreen(signature: signature));
    });
  }
  void _editSignature(Signature signature) {
    // Navigate to details / preview screen
    Future.microtask(() {
      Get.to(() => SignatureEditScreen(signatureId: signature.id));
    });
  }

  void _showSignatureOptions(Signature signature) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Signature Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // View
              ListTile(
                leading: const Icon(Icons.edit, color: grailGold),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(Get.context!);
                  Future.microtask(() => _editSignature(signature));
                },
              ),

              // Delete
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(Get.context!);
                  Future.microtask(() => _confirmDelete(signature.id));
                },
              ),

              const SizedBox(height: 10),

              // Cancel
              ListTile(
                title: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () => Navigator.pop(Get.context!),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int signatureId) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this signature?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        try {
          await ApiService().callApiWithMap(
            'signature/$signatureId',
            'DELETE',
            mapData: {},
          );

          Get.snackbar('Success', 'Signature deleted successfully');

          // Refresh list
          final controller = Get.find<SignatureAssignerController>();
          controller.fetchSignatures();
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to delete signature',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: grailGold,
        backgroundColor: Colors.grey[200],
        labelStyle:
        TextStyle(color: isSelected ? Colors.white : Colors.black),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
