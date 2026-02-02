import 'package:intl/intl.dart';

import 'ExportImports.dart';

Widget modelAvatar({
  required String? imageUrl,
  required String name,
  double radius = 12,
}) {
  final uri = Uri.https(
    'ui-avatars.com',
    '/api/',
    {
      'name': name.trim(),
      'background': 'random',
      'size': (radius * 2).toInt().toString(),
      'v': DateTime.now().millisecondsSinceEpoch.toString(), // cache buster
    },
  );

  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey.shade200,
    child: ClipOval(
      child: Image.network(
        imageUrl ?? uri.toString(),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'assets/images/default_avatar.png',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          );
        },
      ),
    ),
  );
}

String roleLabel(String role) {
  switch (role) {
    case 'admin':
      return 'Admin';
    case 'digital_creator':
      return 'Digital Creator';
    case 'team_member':
      return 'Team Member';
    case 'manager':
      return 'Manager';
    default:
      return role;
  }
}

String formattedDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
}
