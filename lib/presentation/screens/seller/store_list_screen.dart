import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/seller_model.dart';
import '../../../data/services/buyer_service.dart';
import 'store_detail_screen.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final BuyerService _buyerService = BuyerService();
  final TextEditingController _searchController = TextEditingController();
  List<SellerModel> _sellers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final sellers = await _buyerService.getSellers(search: search);
      setState(() {
        _sellers = sellers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching stores: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: "All Stores".text.xl2.bold.make(),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchSellers(search: _searchController.text),
                    child: _sellers.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 120),
                              "No stores found".text.make().centered(),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _sellers.length,
                            itemBuilder: (context, index) {
                              final seller = _sellers[index];
                              return _buildStoreCard(seller);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search stores...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onSubmitted: (value) => _fetchSellers(search: value),
      ),
    );
  }

  Widget _buildStoreCard(SellerModel seller) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = seller.avatar;

    Widget imageWidget;
    if (imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',').last;
          imageWidget = Image.memory(
            base64Decode(base64String),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.store),
          );
        } catch (e) {
          imageWidget = const Icon(Icons.store);
        }
      } else if (imageUrl.startsWith('http')) {
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.store),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: '$baseUrl$imageUrl',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.store),
        );
      }
    } else {
      imageWidget = const Icon(Icons.store, color: AppTheme.secondaryColor);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreDetailScreen(sellerId: seller.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Store Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget,
                ),
              ),
              const SizedBox(width: 16),
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        seller.companyName.text.bold.size(16).make(),
                        if (seller.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (seller.address != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: seller.address!.text.xs.color(Colors.grey).ellipsis.maxLines(1).make(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    "${seller.adCount} Active Listings".text.xs.color(AppTheme.secondaryColor).semiBold.make(),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
