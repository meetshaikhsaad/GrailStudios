import '../helpers/ExportImports.dart';

class ContentVaultDetailsController extends GetxController {
  final int folderUserId;

  ContentVaultDetailsController(this.folderUserId);

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var files = <ContentVaultFile>[].obs;

  final int limit = 10;
  int skip = 0;
  bool hasMore = true;

  // media type filter
  var selectedMediaType = 'all'.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchFiles(reset: true);
    _initScrollListener();
  }

  void _initScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200 &&
          !isMoreLoading.value &&
          hasMore) {
        fetchFiles();
      }
    });
  }

  Future<void> fetchFiles({bool reset = false}) async {
    if (reset) {
      skip = 0;
      hasMore = true;
      files.clear();
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      final mediaQuery =
      selectedMediaType.value == 'all'
          ? ''
          : '&media_type=${selectedMediaType.value}';

      final response = await ApiService().callApiWithMap(
        'content_vault/files/$folderUserId?skip=$skip&limit=$limit$mediaQuery',
        'GET',
        mapData: {},
      );

      if (response is Map && response['data'] is List) {
        final List newFiles = response['data'];

        files.addAll(
          newFiles.map((e) => ContentVaultFile.fromJson(e)).toList(),
        );

        skip += limit;
        hasMore = newFiles.length == limit;
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load vault files',
        backgroundColor: grailErrorRed,
      );
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void changeMediaType(String type) {
    selectedMediaType.value = type;
    fetchFiles(reset: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
