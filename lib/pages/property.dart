import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/MessagesPage.dart';
import 'package:sakkeny_app/pages/Payment%20Screens/review_and_continue_screen.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/services/property_service.dart';

class PropertyDetailsPage extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  bool isFavorite = false;
  bool _isCheckingFavorite = true;
  final PropertyService _propertyService = PropertyService();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // ✅ Check if property is already saved
  Future<void> _checkIfSaved() async {
    bool saved = await _propertyService.isPropertySaved(widget.property.propertyId);
    if (mounted) {
      setState(() {
        isFavorite = saved;
        _isCheckingFavorite = false;
      });
    }
  }

  // ✅ Toggle save/unsave
  Future<void> _toggleSave() async {
    setState(() => _isCheckingFavorite = true);
    
    bool success = await _propertyService.toggleSavedProperty(widget.property.propertyId);
    
    if (success && mounted) {
      setState(() {
        isFavorite = !isFavorite;
        _isCheckingFavorite = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? '❤️ Added to favorites' : '💔 Removed from favorites'),
          duration: const Duration(seconds: 2),
          backgroundColor: isFavorite ? Colors.green : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      setState(() => _isCheckingFavorite = false);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Failed to update favorites'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPropertyImage(widget.property),
                    BuildPropertyHeader(
                      property: widget.property,
                      isFavorite: isFavorite,
                      isLoading: _isCheckingFavorite,
                      onFavoriteToggle: _toggleSave,
                    ),
                    _buildDescription(widget.property),
                    _buildAmenities(widget.property),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }
}

// ============================================
// APP BAR
// ============================================
Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Text(
          'Property Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement share functionality
          },
          icon: const Icon(Icons.share_outlined),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

// ============================================
// PROPERTY IMAGE CAROUSEL
// ============================================
class _PropertyImageCarousel extends StatefulWidget {
  final PropertyModel property;

  const _PropertyImageCarousel({required this.property});

  @override
  State<_PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<_PropertyImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280,
          margin: const EdgeInsets.all(16),
          child: PageView.builder(
            itemCount: widget.property.images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.property.images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF276152),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        // Price Badge
        Positioned(
          top: 26,
          right: 26,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EGP ${widget.property.price.toStringAsFixed(0)}/Month',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        // Page Indicators
        if (widget.property.images.length > 1)
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.property.images.length,
                (index) => Container(
                  width: index == _currentPage ? 24 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Widget _buildPropertyImage(PropertyModel property) {
  return _PropertyImageCarousel(property: property);
}

// ============================================
// PROPERTY HEADER (Title, Location, Rating, Favorite)
// ============================================
class BuildPropertyHeader extends StatelessWidget {
  final PropertyModel property;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavoriteToggle;

  const BuildPropertyHeader({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.isLoading,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF276152),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                      ),
                onPressed: isLoading ? null : onFavoriteToggle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property.location.fullAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${property.rating}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${property.reviews} reviews)',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// DESCRIPTION SECTION
// ============================================
Widget _buildDescription(PropertyModel property) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          property.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
      ],
    ),
  );
}

// ============================================
// AMENITIES SECTION
// ============================================
Widget _buildAmenities(PropertyModel property) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What this place offers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAmenityItem(
                property.isWifi ? Icons.wifi : Icons.wifi_off,
                'Wifi',
                property.isWifi ? Colors.green[100]! : Colors.red[100]!,
              ),
            ),
            Expanded(
              child: _buildAmenityItem(
                Icons.weekend_outlined,
                '${property.livingrooms}\nLivingroom',
              ),
            ),
            Expanded(
              child: _buildAmenityItem(
                Icons.bathroom_outlined,
                '${property.bathrooms}\nBathroom',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAmenityItem(
                Icons.bed_outlined,
                '${property.bedrooms}\nBedroom',
              ),
            ),
            Expanded(
              child: _buildAmenityItem(
                Icons.kitchen_outlined,
                '${property.kitchens}\nKitchen',
              ),
            ),
            Expanded(
              child: _buildAmenityItem(
                Icons.balcony_outlined,
                '${property.balconies}\nBalcony',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildAmenityItem(
  IconData icon,
  String label, [
  Color color = Colors.white,
]) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
        ),
      ],
    ),
  );
}

// ============================================
// BOTTOM BUTTONS (Message & Book Now)
// ============================================
Widget _buildBottomButtons(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MessagesPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276152),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReviewAndContinueScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276152),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );
}