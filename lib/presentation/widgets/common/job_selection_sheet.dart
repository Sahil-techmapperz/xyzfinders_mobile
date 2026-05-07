import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class JobSelectionSheet extends StatelessWidget {
  final VoidCallback onGetHired;
  final VoidCallback onFindJobs;

  const JobSelectionSheet({
    super.key,
    required this.onGetHired,
    required this.onFindJobs,
  });

  static void show(BuildContext context, {required VoidCallback onGetHired, required VoidCallback onFindJobs}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => JobSelectionSheet(
        onGetHired: onGetHired,
        onFindJobs: onFindJobs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              "Find a Job and Hire Talent".text.xl.bold.make(),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          _buildOption(
            title: "Get Hire",
            subtitle: "Find the right person for the job",
            icon: Icons.work_outline,
            onTap: () {
              Navigator.pop(context);
              onGetHired();
            },
          ),
          const SizedBox(height: 16),
          _buildOption(
            title: "Find Jobs",
            subtitle: "Get hire at the job you want",
            icon: Icons.person_search_outlined,
            onTap: () {
              Navigator.pop(context);
              onFindJobs();
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.deepOrange.shade300, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.text.bold.size(16).make(),
                  const SizedBox(height: 4),
                  subtitle.text.color(Colors.grey.shade600).size(13).make(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
