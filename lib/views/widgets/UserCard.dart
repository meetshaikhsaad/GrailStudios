import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                modelAvatar(
                imageUrl: user.profilePictureUrl,
                  name: user.fullName, // or fullName / username
                  radius: 26,
                ),
                const SizedBox(width: 14),
                Expanded(child:  _nameAndRole(),),
              ],
            ),
            _content()
            // Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _managerRow(),
        const SizedBox(height: 10),
        _assignedModels(),
        const SizedBox(height: 10),
        _dateRow(),
      ],
    );
  }

  Widget _nameAndRole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roleLabel(user.role),
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _managerRow() {
    // if (user.manager == null) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        text: 'Manager: ',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
        children: [
          TextSpan(
            text: user.manager == null ? '---' : user.manager!.fullName,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignedModels() {
    // if (user.modelsUnderManager.isEmpty) return const SizedBox.shrink();
    // if(user.role != 'manager' && user.role != 'team_member') return const SizedBox.shrink();

    // Limit avatars to 2, show count if more
    final displayModels = user.modelsUnderManager.take(2).toList();
    final extraCount = user.modelsUnderManager.length - displayModels.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Assigned Models',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (!user.modelsUnderManager.isEmpty)
            SizedBox(
              width: 70,
              height: 26,
              child: Stack(
                children: [
                  for (int i = 0; i < displayModels.length; i++)
                    Positioned(
                      left: i * 18.0,
                      child: modelAvatar(
                        imageUrl: displayModels[i].profilePictureUrl,
                        name: displayModels[i].fullName, // or fullName / username
                        radius: 12,
                      ),
                    ),
                  if (extraCount > 0)
                    Positioned(
                      left: displayModels.length * 18.0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.amber,
                        child: Text(
                          '$extraCount+',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (user.modelsUnderManager.isEmpty)
            const Text(
              '---',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _dateRow() {
    final createdAt = user.createdAt;

    return Text(
      formattedDate(createdAt),
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }

}
