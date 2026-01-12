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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(user.profilePictureUrl),
            const SizedBox(width: 14),
            Expanded(child: _content()),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    return CircleAvatar(
      radius: 28,
      backgroundImage: url != null
          ? NetworkImage(url)
          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _nameAndRole(),
        const SizedBox(height: 8),
        _managerRow(),
        const SizedBox(height: 10),
        _assignedModels(),
        const SizedBox(height: 10),
        _dateRow(),
      ],
    );
  }

  Widget _nameAndRole() {
    return Row(
      children: [
        Expanded(
          child: Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role,
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
    if (user.manager == null) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        text: 'Manager: ',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
        children: [
          TextSpan(
            text: user.manager!.fullName,
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
    if (user.modelsUnderManager.isEmpty) return const SizedBox.shrink();

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
          SizedBox(
            width: 70,
            height: 26,
            child: Stack(
              children: [
                for (int i = 0; i < displayModels.length; i++)
                  Positioned(
                    left: i * 18.0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: displayModels[i].profilePictureUrl != null
                          ? NetworkImage(displayModels[i].profilePictureUrl!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
        ],
      ),
    );
  }

  Widget _dateRow() {
    final lastLogin = user.lastLogin ?? user.createdAt;
    final formattedDate = "${lastLogin.day.toString().padLeft(2, '0')}-"
        "${lastLogin.month.toString().padLeft(2, '0')} "
        "${lastLogin.hour.toString().padLeft(2, '0')}:"
        "${lastLogin.minute.toString().padLeft(2, '0')}";
    return Text(
      formattedDate,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}
