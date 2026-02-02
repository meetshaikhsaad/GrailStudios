import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import '../../helpers/ExportImports.dart';

class ContentVaultViewerScreen extends StatefulWidget {
  final String url;

  const ContentVaultViewerScreen({Key? key, required this.url})
      : super(key: key);

  @override
  State<ContentVaultViewerScreen> createState() =>
      _ContentVaultViewerScreenState();
}

class _ContentVaultViewerScreenState extends State<ContentVaultViewerScreen> {
  String? localPath;
  bool isLoading = true;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  Future<void> _prepareFile() async {
    final ext = _extension;

    // Download files only if needed
    if (['pdf', 'docx'].contains(ext)) {
      final file = await _downloadFile(widget.url);
      localPath = file.path;
    }

    if (_isVideo) {
      videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await videoController!.initialize();
      videoController!.play();
    }

    setState(() => isLoading = false);
  }

  Future<File> _downloadFile(String url) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${url.split('/').last}');
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  String get _extension => widget.url.split('.').last.toLowerCase();

  bool get _isImage =>
      ['png', 'jpg', 'jpeg', 'gif'].contains(_extension);

  bool get _isVideo =>
      ['mp4', 'mov', 'webm'].contains(_extension);

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Preview',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildViewer(),

      // 🔹 PLAY / PAUSE BUTTON (VIDEO ONLY)
      floatingActionButton: _isVideo && videoController != null
          ? FloatingActionButton(
        backgroundColor: grailGold,
        onPressed: () {
          setState(() {
            videoController!.value.isPlaying
                ? videoController!.pause()
                : videoController!.play();
          });
        },
        child: Icon(
          videoController!.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      )
          : null,
    );
  }

  Widget _buildViewer() {
    // ---------------- IMAGE ----------------
    if (_isImage) {
      return Center(
        child: PhotoView(
          imageProvider: NetworkImage(widget.url),
          backgroundDecoration:
          const BoxDecoration(color: Colors.white),
        ),
      );
    }

    // ---------------- VIDEO ----------------
    if (_isVideo && videoController != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: VideoPlayer(videoController!),
        ),
      );
    }

    // ---------------- PDF ----------------
    if (_extension == 'pdf' && localPath != null) {
      return PDFView(
        filePath: localPath!,
        enableSwipe: true,
        autoSpacing: true,
        pageFling: true,
      );
    }

    // ---------------- DOCX ----------------
    if (_extension == 'docx' && localPath != null) {
      return DocxView.path(
        localPath!,
        config: DocxViewConfig(
          backgroundColor: Colors.white,
          showPageBreaks: true,
          pageMode: DocxPageMode.paged,
        ),
      );
    }

    // ---------------- FALLBACK ----------------
    return const Center(
      child: Text(
        'Unsupported file format',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  //call this function for adding downloading the attachment functionality
  Future<void> _downloadAttachment(String url, {BuildContext? context}) async {
    try {
      final fileName = url.split('/').last;

      // Use the DownloadService
      await DownloadService.instance.downloadFile(
        url,
        fileName,
        context: context,
      );
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
      print("Download failed: $e");
    }
  }
}
