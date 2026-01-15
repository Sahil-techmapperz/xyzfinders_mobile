import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/product_provider.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/featured_carousel.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ProductProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().fetchProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Discover".text.xl2.bold.make(),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildShimmerLoading();
          }

          if (provider.error != null && provider.products.isEmpty) {
            return Center(
              child: VStack([
                const Icon(Icons.error_outline, size: 64, color: Vx.gray400),
                16.heightBox,
                provider.error!.text.color(Vx.gray600).center.make(),
                16.heightBox,
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Retry'),
                ),
              ], crossAlignment: CrossAxisAlignment.center).p16(),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      20.heightBox,
                      FeaturedCarousel(products: provider.products),
                      20.heightBox,
                      "Recent Listings".text.xl.bold.make().pOnly(left: 16, bottom: 12),
                    ],
                  ),
                ),
                if (provider.products.isEmpty)
                   SliverFillRemaining(
                     child: Center(child: "No products found".text.make()),
                   )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                          ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideY(begin: 0.1);
                        },
                        childCount: provider.products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    ),
                  ),
                if (provider.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

