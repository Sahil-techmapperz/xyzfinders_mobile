import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';

class EducationDetailScreen extends StatefulWidget {
  final int productId;
  final String? title;

  const EducationDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceSection(),
                      const SizedBox(height: 12),
                      (widget.title ?? "Mathematics Home Tuition (Class 10-12)").text.xl.bold.make(),
                      const SizedBox(height: 16),
                      _buildMetaInfoLine(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          "By Sumit Sharma (M.Sc. Mathematics)".text.gray600.semiBold.size(13).make(),
                        ],
                      ),
                      const Divider(height: 32),
                      "CBSE | ICSE | State Board | Competitive Exams".text.bold.size(13).make(),
                      const SizedBox(height: 20),
                      "Specification".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildOverviewTable(),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: "See More Details".text.orange500.semiBold.make(),
                        ),
                      ),
                      const Divider(height: 32),
                      "Description".text.bold.size(15).make(),
                      const SizedBox(height: 12),
                      "Comprehensive mathematics coaching for students of class 10 to 12. Focus on conceptual clarity, problem-solving techniques, and exam preparation. Personalized attention and regular mock tests included."
                          .text.gray600.size(13).lineHeight(1.5).maxLines(3).ellipsis.make(),
                      const SizedBox(height: 8),
                      "Read More".text.orange500.bold.make(),
                      const SizedBox(height: 16),
                      "Posted on : 10-Mar-2026".text.gray500.size(13).make(),
                      const Divider(height: 48),
                      "Key Features".text.bold.size(15).make(),
                      const SizedBox(height: 16),
                      _buildAmenities(),
                      const SizedBox(height: 32),
                      _buildSellerCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBackButton(),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
    );
  }

  Widget _buildImageHeader() {
    return SliverAppBar(
      expandedHeight: 350,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1596495573105-08246bc6ec68?auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: Colors.white, size: 10),
                    const SizedBox(width: 4),
                    "1/10".text.white.size(8).bold.make(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        "₹ 500".text.xl3.bold.color(AppTheme.secondaryColor).make(),
        "/per hour".text.xl2.bold.color(AppTheme.secondaryColor).make(),
      ],
    );
  }

  Widget _buildMetaInfoLine() {
    return Row(
      children: [
        _buildMetaItem(Icons.calendar_month_outlined, "Home Tuition"),
        const SizedBox(width: 24),
        _buildMetaItem(Icons.star_outline, "8+ Yrs Exp"),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 6),
        label.text.gray700.size(14).bold.make(),
      ],
    );
  }

  Widget _buildOverviewTable() {
    final specs = [
      {"label": "Mode", "value": "Offline"},
      {"label": "Level", "value": "Class 10-12"},
      {"label": "Subject", "value": "Mathematics"},
      {"label": "Duration", "value": "1.5 Hours"},
      {"label": "Batch Size", "value": "Individual/Group"},
    ];

    return Column(
      children: specs.map((spec) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            spec['label']!.text.gray500.size(14).make(),
            spec['value']!.text.bold.size(14).make(),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAmenities() {
    final List<Map<String, dynamic>> features = [
      {"icon": Icons.check_circle_outline, "label": "Individual Focus"},
      {"icon": Icons.article_outlined, "label": "Study Material"},
      {"icon": Icons.quiz_outlined, "label": "Mock Tests"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: features.map((item) => Container(
          height: 60,
          width: 60,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3), width: 1.0),
          ),
          child: Icon(item['icon'] as IconData, size: 28, color: Colors.black87).centered(),
        )).toList(),
      ),
    );
  }

  Widget _buildSellerCard() {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/45.jpg"),
          ),
        ),
        const SizedBox(height: 12),
        "Sumit Sharma".text.bold.size(16).center.make(),
        "Certified Tutor".text.gray500.size(14).make(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Active Since 2021".text.gray600.size(12).make(),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call, color: Color(0xFFD81B60), size: 24),
                    const SizedBox(width: 10),
                    "Call Tutor".text.color(const Color(0xFFD81B60)).xl.bold.make(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble, color: Color(0xFF1E88E5), size: 24),
                    const SizedBox(width: 10),
                    "Chat".text.color(const Color(0xFF1E88E5)).xl.bold.make(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
