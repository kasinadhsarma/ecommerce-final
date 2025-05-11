import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_utils.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final isFavorite =
        productProvider.favoriteProductIds.contains(product.id.toString());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with favorite button
            Stack(
              children: [
                // Product image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 5,
                  right: 5,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        productProvider.toggleFavorite(product.id.toString());
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with ellipsis
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle2,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    CurrencyUtils.formatCurrency(product.price),
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.rate.toString(),
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.rating.count})',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headline3.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 2,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    Key? key,
    required this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: AppTextStyles.subtitle1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText && !_showPassword,
      validator: widget.validator,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              )
            : widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 10,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
            ),
            foregroundColor: textColor ?? AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: Size(width, height),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: Size(width, height),
          );

    final Widget buttonContent = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.button.copyWith(
                  color: isOutlined
                      ? (textColor ?? AppColors.primary)
                      : (textColor ?? AppColors.onPrimary),
                ),
              ),
            ],
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.categoryName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            categoryName.toUpperCase(),
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
