import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_utils.dart';
import '../models/product_model.dart';
import 'product/product_details_screen.dart';
import 'product/category_products_screen.dart';
import 'product/search_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePageContent(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await productProvider.initProducts();
    await cartProvider.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${cartProvider.itemCount}'),
              isLabelVisible: cartProvider.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ECommerce Shop'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show a snackbar for now since notifications screen is not implemented yet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const LoadingIndicator(message: 'Loading products...')
          : productProvider.error != null
              ? ErrorDisplay(
                  errorMessage: productProvider.error!,
                  onRetry: () => productProvider.initProducts(),
                )
              : RefreshIndicator(
                  onRefresh: () => productProvider.initProducts(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message
                          Text(
                            'Hello, ${user?.name ?? 'Guest'}!',
                            style: AppTextStyles.headline2,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What are you looking for today?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Featured products
                          _buildSectionHeader('Featured Products', () {}),
                          const SizedBox(height: 8),
                          _buildFeaturedProductsList(
                            productProvider.featuredProducts,
                            context,
                          ),
                          const SizedBox(height: 24),

                          // Categories
                          _buildSectionHeader('Categories', () {}),
                          const SizedBox(height: 8),
                          _buildCategoriesList(
                            productProvider.categories,
                            context,
                          ),
                          const SizedBox(height: 24),

                          // Popular products
                          _buildSectionHeader('All Products', () {}),
                          const SizedBox(height: 8),
                          _buildProductGrid(
                            productProvider.products,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headline3,
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsList(
      List<Product> products, BuildContext context) {
    return SizedBox(
      height: 220,
      child: products.isEmpty
          ? const Center(child: Text('No featured products available.'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: 160,
                  child: ProductCard(
                    product: product,
                    onTap: () => _navigateToProductDetails(context, product),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCategoriesList(List<String> categories, BuildContext context) {
    return SizedBox(
      height: 100,
      child: categories.isEmpty
          ? const Center(child: Text('No categories available.'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CategoryCard(
                      categoryName: category,
                      onTap: () => _navigateToCategory(context, category),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductGrid(List<Product> products, BuildContext context) {
    return products.isEmpty
        ? const Center(child: Text('No products available.'))
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => _navigateToProductDetails(context, product),
              );
            },
          );
  }

  void _navigateToProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(category: category),
      ),
    );
  }
}
