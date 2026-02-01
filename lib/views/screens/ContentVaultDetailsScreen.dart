import '../../helpers/ExportImports.dart';

class ContentVaultDetailsScreen extends StatelessWidget {
  final UserData folderUser;

  const ContentVaultDetailsScreen({Key? key, required this.folderUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(ContentVaultDetailsController(folderUser.id));

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: folderUser.fullName,
        scaffoldKey: scaffoldKey,
        showBackButton: true,
        notificationVisibility: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ---------- FILTER CHIPS ----------
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                _filterChip(controller, 'all', 'All'),
                _filterChip(controller, 'image', 'Images'),
                _filterChip(controller, 'video', 'Videos'),
                _filterChip(controller, 'document', 'Documents'),
              ],
            ),
          )),

          // ---------- GRID ----------
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.files.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.files.isEmpty) {
                return const Center(child: Text('No files found'));
              }

              return GridView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.files.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index >= controller.files.length) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final file = controller.files[index];

                  return GestureDetector(
                    onTap: () {
                      Get.to(
                            () => ContentVaultViewerScreen(url: file.fileUrl),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.grey[200],
                        child: Image.network(
                          file.thumbnailUrl ?? file.fileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.insert_drive_file,
                            size: 40,
                          ),
                        ),
                      ),
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

  Widget _filterChip(
      ContentVaultDetailsController controller,
      String value,
      String label,
      ) {
    final isSelected = controller.selectedMediaType.value == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: grailGold.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? grailGold : Colors.black,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => controller.changeMediaType(value),
      ),
    );
  }
}
