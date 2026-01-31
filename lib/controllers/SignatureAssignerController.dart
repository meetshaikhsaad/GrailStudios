import '../../helpers/ExportImports.dart';

class SignatureAssignerController extends GetxController {
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasError = false.obs;

  var signatures = <Signature>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = ''.obs; // Pending / Signed / Expired

  int _currentPage = 0;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchSignatures();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    fetchSignatures();
  }

  void onStatusChanged(String status) {
    selectedStatus.value = status;
    fetchSignatures();
  }

  Future<void> fetchSignatures({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      _currentPage = 0;
      _hasMore = true;
    }

    try {
      String url =
          'signature/?skip=$_currentPage&limit=$_limit';

      if (searchQuery.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }
      if (selectedStatus.isNotEmpty) {
        url += '&status=${selectedStatus.value}';
      }

      final response = await ApiService().callApiWithMap(
        url,
        'GET',
        mapData: {},
      );

      final result = SignatureListResponse.fromJson(response);

      if (loadMore) {
        signatures.addAll(result.signatures);
      } else {
        signatures.assignAll(result.signatures);
      }

      _hasMore = result.signatures.length == _limit;
      _currentPage++;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}
