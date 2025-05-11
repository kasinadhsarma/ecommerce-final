import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common_widgets.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      _products = await productProvider.getProductsByCategory(widget.category);
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading products...')
          : _error != null
              ? ErrorDisplay(
                  errorMessage: _error!,
                  onRetry: _loadCategoryProducts,
                )
              : _products.isEmpty
                  ? const Center(
                      child: Text('No products found in this category.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCategoryProducts,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => _navigateToProductDetails(product),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }
}
