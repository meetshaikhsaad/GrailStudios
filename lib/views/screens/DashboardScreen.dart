import '../../helpers/ExportImports.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: screensBackground,
      key: scaffoldKey,
      appBar: AppBarWidget.appBarWave(
        title: 'Home',
        scaffoldKey: scaffoldKey,
        // notificationCount: 3, // optional
      ),
      drawer: AppBarWidget.appDrawer(scaffoldKey),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshDashboard,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Cards
                _buildStatsRow(stats.metrics),

                const SizedBox(height: 24),

                // Task Completion
                _buildCompletionSection(stats.completion),

                const SizedBox(height: 24),

                // Missing Content
                _buildMissingContentSection(stats.lists.missingContent),

                const SizedBox(height: 24),

                // Recent Document Status
                _buildRecentDocumentsSection(stats.lists.documents),

                const SizedBox(height: 24),

                // Time to Completion
                _buildTimeToCompletion(stats.time),

                const SizedBox(height: 5), // bottom padding
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: AppBarWidget.appBottomNav(
        0,
            (index) async {
          final activeUser = await ApiService.getSavedUser();
          final role = activeUser?.user.role;

          switch (index) {
          /// 🏠 HOME → Dashboard (Everyone)
            case 0:
              if (Get.currentRoute != AppRoutes.dashboard) {
                Get.offAllNamed(AppRoutes.dashboard);
              }
              break;

          /// 📋 TASKS
            case 1:
              if (role == 'admin' || role == 'manager' || role == 'team_member') {
                Get.offAllNamed(AppRoutes.tasksAssigner);
              } else if (role == 'digital_creator') {
                Get.offAllNamed(AppRoutes.tasksSubmission);
              }
              break;

          /// ✔ COMPLIANCE (Signatures)
            case 2:
              if (role == 'admin' || role == 'manager' || role == 'team_member') {
                Get.offAllNamed(AppRoutes.signatureAssigner);
              } else if (role == 'digital_creator') {
                Get.offAllNamed(AppRoutes.signatureSigner);
              }
              break;

          /// 📂 CONTENT (Only Admin & Manager)
            case 3:
              if (role == 'admin' || role == 'manager') {
                Get.offAllNamed(AppRoutes.contentVault);
              }else if (role == 'digital_creator' || role == 'team_member'){
                // announcement routing for these
              }
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatsRow(Metrics metrics) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Overdue Tasks', metrics.overdue.toString(), grailGold),
            _buildStatCard('Missing Content', metrics.missing.toString(), grailGold),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Unsigned Docs', metrics.unsigned.toString(), grailGold),
            _buildStatCard('Blocked Tasks', metrics.blocked.toString(), grailGold),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionSection(Completion completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Task Completion Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall Performance'),
                  Text(
                    '${completion.overallRate}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completion.overallRate / 100,
                backgroundColor: Colors.grey[300],
                color: grailGold, // or Colors.blue
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissingContentSection(List<MissingContentItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Action Required: Missing Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.transparent),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: separators),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // TODO: Add routing here
                  // Example:
                  // Get.to(() => MissingContentDetailsScreen(user: item));
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      /// LEFT SIDE (Name + Missing Count)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                text: 'missing items - ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                                children: [
                                  TextSpan(
                                    text: item.count.toString(),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT ARROW
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocumentsSection(List<DocumentItem> documents) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent Document Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.transparent),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: separators),
            itemBuilder: (context, index) {
              final doc = documents[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // TODO: Add navigation
                  // Get.to(() => DocumentDetailsScreen(doc: doc));
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      /// LEFT SIDE (User + Document)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.userName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc.docName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// STATUS BADGE
                      _buildStatusBadge(doc),

                      const SizedBox(width: 10),

                      /// RIGHT ARROW
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DocumentItem doc) {
    final Color textColor = doc.statusColor;
    final Color bgColor = textColor.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        doc.status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimeToCompletion(TimeData time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time-to-Completion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${time.avgDays} Days',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.green, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Avg. task completion',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}