import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/common_widgets.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({Key? key}) : super(key: key);

  @override
  _StoreDetailsScreenState createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Store> _stores = [
    Store(
      id: '1',
      name: 'Main Store',
      address: '123 Shopping Street, Retail City, RC 12345',
      phone: '+1 (555) 123-4567',
      email: 'mainstore@ecommerce.com',
      hours: {
        'Monday': '9:00 AM - 8:00 PM',
        'Tuesday': '9:00 AM - 8:00 PM',
        'Wednesday': '9:00 AM - 8:00 PM',
        'Thursday': '9:00 AM - 8:00 PM',
        'Friday': '9:00 AM - 9:00 PM',
        'Saturday': '10:00 AM - 9:00 PM',
        'Sunday': '11:00 AM - 6:00 PM',
      },
      amenities: [
        'Free Wifi',
        'Parking Available',
        'Curbside Pickup',
        'Customer Service Desk',
        'Returns & Exchanges',
        'Gift Wrapping',
      ],
      images: [
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
        'https://images.unsplash.com/photo-1555529771-122e5d9f2341',
        'https://images.unsplash.com/photo-1604719312566-8912e9c8a213',
      ],
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    Store(
      id: '2',
      name: 'Downtown Branch',
      address: '456 Market Avenue, Metro City, MC 67890',
      phone: '+1 (555) 987-6543',
      email: 'downtown@ecommerce.com',
      hours: {
        'Monday': '8:00 AM - 7:00 PM',
        'Tuesday': '8:00 AM - 7:00 PM',
        'Wednesday': '8:00 AM - 7:00 PM',
        'Thursday': '8:00 AM - 7:00 PM',
        'Friday': '8:00 AM - 8:00 PM',
        'Saturday': '9:00 AM - 8:00 PM',
        'Sunday': '10:00 AM - 5:00 PM',
      },
      amenities: [
        'Free Wifi',
        'Underground Parking',
        'Coffee Shop',
        'Personal Shopper',
        'Express Checkout',
        'Delivery Services',
      ],
      images: [
        'https://images.unsplash.com/photo-1604709177225-055f99402ea3',
        'https://images.unsplash.com/photo-1587467512961-120760940315',
        'https://images.unsplash.com/photo-1567958451986-2de427a4a0be',
      ],
      latitude: 40.7282,
      longitude: -73.9942,
    ),
  ];

  int _selectedStoreIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStore = _stores[_selectedStoreIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Locations'),
      ),
      body: Column(
        children: [
          // Store selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedStoreIndex,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: List.generate(_stores.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(_stores[index].name),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStoreIndex = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(
                icon: Icon(Icons.info_outline),
                text: 'Info',
              ),
              Tab(
                icon: Icon(Icons.access_time),
                text: 'Hours',
              ),
              Tab(
                icon: Icon(Icons.photo_library_outlined),
                text: 'Gallery',
              ),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Info tab
                _buildInfoTab(selectedStore),

                // Hours tab
                _buildHoursTab(selectedStore),

                // Gallery tab
                _buildGalleryTab(selectedStore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(Store store) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and address
          Text(
            store.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  store.address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          InkWell(
            onTap: () => _makePhoneCall(store.phone),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    store.phone,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Email
          InkWell(
            onTap: () => _sendEmail(store.email),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.email,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    store.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Amenities
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: store.amenities.map((amenity) {
              return Chip(
                label: Text(amenity),
                backgroundColor: Colors.deepPurple.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Directions
          const Text(
            'Get Directions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          CustomButton(
            text: 'Open in Maps',
            icon: Icons.map,
            onPressed: () => _openInMaps(store),
          ),

          const SizedBox(height: 24),

          // Copy address
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Address'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _copyAddress(context, store.address),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursTab(Store store) {
    final now = DateTime.now();
    final today = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][now.weekday - 1];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today's hours callout
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.hours[today] ?? 'Closed',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Weekly hours
        const Text(
          'Weekly Hours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Days of the week
        ...[
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ].map((day) {
          final isToday = day == today;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.deepPurple : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    store.hours[day] ?? 'Closed',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.deepPurple : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        // Special hours notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.amber,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Holiday hours may vary. Please check our website or call the store for special holiday hours.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryTab(Store store) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: store.images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, store.images, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              store.images[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  void _openInMaps(Store store) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${store.latitude},${store.longitude}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFullScreenImage(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageGallery(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class Store {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final Map<String, String> hours;
  final List<String> amenities;
  final List<String> images;
  final double latitude;
  final double longitude;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.hours,
    required this.amenities,
    required this.images,
    required this.latitude,
    required this.longitude,
  });
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Image ${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
