import 'package:intl/intl.dart';
import '../../helpers/ExportImports.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to task detail
          Get.snackbar('Task', 'Task detail coming soon!');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                task.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.status,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'In Progress',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: task.assignee.profilePictureUrl != null
                        ? NetworkImage(task.assignee.profilePictureUrl!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.assignee.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    task.dueDate != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(task.dueDate!.toLocal())
                        : 'No due date',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}