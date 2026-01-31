import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/ExportImports.dart';

class DownloadService {
  // Singleton
  DownloadService._privateConstructor();
  static final DownloadService instance = DownloadService._privateConstructor();

  static const MethodChannel _channel =
  MethodChannel('com.grail.studios/downloads');

  /// Download file cross-platform
  Future<void> downloadFile(
      String url,
      String fileName, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("Failed to download file");
      }

      final bytes = response.bodyBytes;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _saveFileAndroid(bytes, fileName, context);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _saveFileIOS(bytes, fileName, context);
      } else {
        throw Exception("Unsupported platform");
      }
    } catch (e) {
      _showMessage("Download failed: $e", context: context);
      debugPrint("Download failed: $e");
    }
  }

  /// ✅ Android: MediaStore → Downloads/GrailStudios
  Future<void> _saveFileAndroid(
      Uint8List bytes,
      String fileName,
      BuildContext? context,
      ) async {
    try {
      await _channel.invokeMethod<bool>('saveToDownloads', {
        'bytes': bytes,
        'fileName': fileName,
      });

      _showMessage(
        "File saved to Downloads/GrailStudios/$fileName",
        context: context,
      );
    } catch (e) {
      _showMessage("Android save failed: $e", context: context);
      debugPrint("Android save failed: $e");
    }
  }

  /// 🍎 iOS: Documents + share sheet
  Future<void> _saveFileIOS(
      Uint8List bytes,
      String fileName,
      BuildContext? context,
      ) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saved to Documents: $fileName")),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Here's your file",
      );
    }
  }

  void _showMessage(String message, {BuildContext? context}) {
    if (context != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } else {
      Get.snackbar(
        "Info",
        message,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
