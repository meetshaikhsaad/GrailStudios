import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../helpers/ExportImports.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String url;

  const DocumentViewerScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  Future<void> _prepareFile() async {
    final ext = widget.url.split('.').last.toLowerCase();

    if (['pdf', 'docx'].contains(ext)) {
      final file = await _downloadFile(widget.url);
      localPath = file.path;
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

  @override
  Widget build(BuildContext context) {
    final ext = widget.url.split('.').last.toLowerCase();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Signature Details',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildViewer(ext),
    );
  }

  Widget _buildViewer(String ext) {
    // ---------------- PDF ----------------
    if (ext == 'pdf' && localPath != null) {
      return PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      );
    }

    if (ext == 'docx' && localPath != null) {
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
      child: Text('Unsupported document format'),
    );
  }
}
