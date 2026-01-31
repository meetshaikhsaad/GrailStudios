import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class SignatureCard extends StatelessWidget {
  final Signature signature;

  const SignatureCard({super.key, required this.signature});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              signature.title.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              signature.description ?? 'No description provided',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Status Chip
            Row(
              children: [
                _statusChip(signature.status),
              ],
            ),

            const SizedBox(height: 12),

            // Signer + Deadline
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: signature.signer.profilePictureUrl != null
                      ? NetworkImage(signature.signer.profilePictureUrl!)
                      : const AssetImage(
                    'assets/images/default_avatar.png',
                  ) as ImageProvider,
                ),
                const SizedBox(width: 8),

                Text(
                  signature.signer.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const Spacer(),

                Text(
                  DateFormat('dd MMM yyyy, hh:mm a')
                      .format(signature.deadline.toLocal()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'signed':
        bgColor = Colors.green.shade50;
        textColor = Colors.green;
        break;
      case 'expired':
        bgColor = Colors.red.shade50;
        textColor = Colors.red;
        break;
      default: // pending
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
