import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A loading indicator optimized for web platforms
///
/// This widget provides different loading indicators for web and mobile platforms,
/// with more elaborate animations and progress reporting for web.
class WebLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? progress;
  final bool isLoading;
  final Widget? child;
  final Color? color;

  const WebLoadingIndicator({
    Key? key,
    this.message,
    this.progress,
    required this.isLoading,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child ?? const SizedBox();
    }

    // Use a different loading indicator for web
    if (kIsWeb) {
      return _WebLoadingOverlay(
        message: message,
        progress: progress,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      // Use a simpler loading indicator for mobile
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(message!),
              ),
          ],
        ),
      );
    }
  }
}

/// A web-specific loading overlay with more elaborate animations
class _WebLoadingOverlay extends StatefulWidget {
  final String? message;
  final double? progress;
  final Color color;

  const _WebLoadingOverlay({
    Key? key,
    this.message,
    this.progress,
    required this.color,
  }) : super(key: key);

  @override
  _WebLoadingOverlayState createState() => _WebLoadingOverlayState();
}

class _WebLoadingOverlayState extends State<_WebLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 180,
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(_opacityAnimation.value),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    value: widget.progress,
                    strokeWidth: 3,
                  ),
                ),
                if (widget.message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      widget.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${(widget.progress! * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A widget that shows a loading indicator while an image is loading on web
class WebImageLoadingIndicator extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const WebImageLoadingIndicator({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        final totalBytes = loadingProgress.expectedTotalBytes;
        final bytesLoaded = loadingProgress.cumulativeBytesLoaded;
        final progress = totalBytes != null ? bytesLoaded / totalBytes : null;

        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: kIsWeb
                ? WebLoadingIndicator(
                    isLoading: true,
                    progress: progress,
                    message: 'Loading image...',
                    color: Theme.of(context).primaryColor,
                  )
                : CircularProgressIndicator(
                    value: progress,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
      },
    );
  }
}
