import 'dart:io';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../helpers/ExportImports.dart';

class InlineDocumentPreview extends StatefulWidget {
  final String url;

  const InlineDocumentPreview({super.key, required this.url});

  @override
  State<InlineDocumentPreview> createState() => _InlineDocumentPreviewState();
}

class _InlineDocumentPreviewState extends State<InlineDocumentPreview> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    final dir = await getTemporaryDirectory();
    final file =
    File('${dir.path}/${widget.url.split('/').last}');

    if (!await file.exists()) {
      final res = await http.get(Uri.parse(widget.url));
      await file.writeAsBytes(res.bodyBytes);
    }

    setState(() {
      localPath = file.path;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ext = widget.url.split('.').last.toLowerCase();

    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ext == 'pdf'
            ? PDFView(
          filePath: localPath!,
          enableSwipe: true,
          autoSpacing: true,
          pageFling: true,
        )
            : DocxView.path(
          localPath!,
          config: const DocxViewConfig(
            backgroundColor: Colors.white,
            showPageBreaks: true,
            pageMode: DocxPageMode.paged,
          ),
        ),
      ),
    );
  }
}
