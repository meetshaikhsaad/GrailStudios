import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';
import '../widgets/DocumentView.dart';

class SignatureViewScreen extends StatelessWidget {
  final Signature signature;

  const SignatureViewScreen({Key? key, required this.signature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Signature Details',
        scaffoldKey: scaffoldKey,
        notificationVisibility: false,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------- Title -------------------
            Center(
              child: Text(
                signature.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // ------------------- Description -------------------
            if (signature.description != null && signature.description!.isNotEmpty)
              Text(
                signature.description!,
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            const SizedBox(height: 20),

            // ------------------- Status -------------------
            Wrap(
              spacing: 8,
              children: [
                _statusChip(signature.status, _getStatusColor(signature.status)),
              ],
            ),
            const SizedBox(height: 24),

            // ------------------- Requester & Signer -------------------
            _userInfoRow('Requested by', signature.requester.fullName,
                signature.requester.profilePictureUrl),
            const SizedBox(height: 12),
            _userInfoRow('Signer', signature.signer.fullName,
                signature.signer.profilePictureUrl),
            const SizedBox(height: 12),

            // ------------------- Dates -------------------
            Text('Created: ${dateFormat.format(signature.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 6),
            Text('Deadline: ${dateFormat.format(signature.deadline)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 24),

            // ------------------- Document / Attachment Preview -------------------
            const Text(
              'Attachment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _attachmentPreview(signature.documentUrl),

            const SizedBox(height: 24),

            // ------------------- Signed Info -------------------
            if (signature.signedAt != null && signature.signedLegalName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Signed Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Signed by: ${signature.signedLegalName} at ${dateFormat.format(signature.signedAt!)}'),
                  if (signature.signerIpAddress != null)
                    Text('IP: ${signature.signerIpAddress}'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ================= USER ROW =================
  Widget _userInfoRow(String label, String name, String? imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageUrl != null
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ],
    );
  }

  // ================= STATUS CHIP =================
  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'signed':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _attachmentPreview(String url) {
    final ext = url.split('.').last.toLowerCase();

    if (['png', 'jpg', 'jpeg', 'gif'].contains(ext)) {
      // Image Preview
      return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoView(
            imageProvider: NetworkImage(url),
            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          ),
        ),
      );
    }
    else if (['pdf', 'docx'].contains(ext)) {
      return InlineDocumentPreview(url: url);
    }

    return const Text('Unsupported attachment type.');
  }

}

