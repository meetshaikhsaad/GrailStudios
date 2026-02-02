import '../../helpers/ExportImports.dart';

class SignatureSignerScreen extends StatelessWidget {
  SignatureSignerScreen({super.key});

  final ScrollController _scrollController = ScrollController();


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
      backgroundColor: screensBackground,
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Signature Signer',
        scaffoldKey: scaffoldKey,
        showBackButton: false,
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
          Obx(() => HorizontalFilterChips(
            options: controller.statusOptionsMap,
            selectedValue: controller.selectedStatus.value,
            onSelectionChanged: (val) {
              controller.selectedStatus.value = val;
              controller.onStatusChanged(val); // fetch / filter tasks
            },
          )),

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
      Get.to(() => SignatureSignSubmitScreen(signature: signature));
    });
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
