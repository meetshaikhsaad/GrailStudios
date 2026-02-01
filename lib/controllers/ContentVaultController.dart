import '../helpers/ExportImports.dart';

class ContentVaultController extends GetxController {
  var isLoading = false.obs;
  var folders = <UserData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchContentVaultFolders();
  }

  Future<void> fetchContentVaultFolders() async {
    isLoading.value = true;

    try {
      final response = await ApiService().callApiWithMap(
        'content_vault/folders',
        'GET',
        mapData: {},
      );

      if (response is Map && response['folders'] is List) {
        folders.assignAll(
          (response['folders'] as List)
              .map((e) => UserData.fromJson(e))
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load content vault',
        backgroundColor: grailErrorRed,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
