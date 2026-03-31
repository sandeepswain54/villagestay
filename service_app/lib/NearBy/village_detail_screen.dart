import 'package:flutter/material.dart';
import 'package:service_app/model/village_model.dart';
import 'package:service_app/NearBy/services/saved_villages_service.dart';

class VillageDetailScreen extends StatefulWidget {
  final Village village;
  final String district;

  const VillageDetailScreen({
    super.key,
    required this.village,
    required this.district,
  });

  @override
  State<VillageDetailScreen> createState() => _VillageDetailScreenState();
}

class _VillageDetailScreenState extends State<VillageDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _isVillageSaved = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkIfVillageSaved();
  }

  Future<void> _checkIfVillageSaved() async {
    final isSaved = await SavedVillagesService.isVillageSaved(widget.village.villageName);
    setState(() {
      _isVillageSaved = isSaved;
    });
  }

  Future<void> _toggleSaveVillage() async {
    if (_isVillageSaved) {
      await SavedVillagesService.removeVillage(widget.village.villageName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Village removed from saved'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await SavedVillagesService.saveVillage(widget.village);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Village saved!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isVillageSaved = !_isVillageSaved;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _toggleSaveVillage,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isVillageSaved ? Icons.favorite : Icons.favorite_border,
                color: _isVillageSaved ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            _buildImageCarousel(),
            // Village Info Section
            _buildVillageInfoSection(),
            // Description Section
            if (widget.village.shortDescription.isNotEmpty)
              _buildSection(
                icon: Icons.description,
                title: 'About',
                content: widget.village.shortDescription,
              ),
            // Experiences Section
            if (widget.village.experiences.isNotEmpty)
              _buildListSection(
                icon: Icons.explore,
                title: 'Experiences',
                items: widget.village.experiences,
              ),
            // Local Products Section
            if (widget.village.localProducts.isNotEmpty)
              _buildListSection(
                icon: Icons.shopping_bag,
                title: 'Local Products',
                items: widget.village.localProducts,
              ),
            // Revenue Streams Section
            if (widget.village.revenueStreams.isNotEmpty)
              _buildListSection(
                icon: Icons.trending_up,
                title: 'Revenue Streams',
                items: widget.village.revenueStreams,
              ),
            // Best Time to Visit Section
            if (widget.village.bestTimeToVisit.isNotEmpty)
              _buildSection(
                icon: Icons.calendar_today,
                title: 'Best Time to Visit',
                content: widget.village.bestTimeToVisit,
              ),
            // Distance Section
            _buildSection(
              icon: Icons.location_on,
              title: 'Distance',
              content:
                  '${widget.village.approxDistanceFromDistrictHqKm} km from district headquarters',
            ),
            // CTA Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate to booking or more details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Explore feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Explore & Book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.village.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.village.images.length,
            itemBuilder: (context, index) {
              return Image.asset(
                'assets/${widget.village.images[index]}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported,
                        size: 48, color: Colors.grey),
                  );
                },
              );
            },
          ),
        ),
        // Image indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.village.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVillageInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Village Name and Category Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.village.villageName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.village.category).withAlpha(51),
              border:
                  Border.all(color: _getCategoryColor(widget.village.category)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.village.category,
              style: TextStyle(
                color: _getCategoryColor(widget.village.category),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // District info
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                widget.district,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildListItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildListItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Icon(Icons.check, size: 14, color: Colors.purple),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'craft':
        return Colors.purple;
      case 'eco':
        return Colors.teal;
      case 'tribal':
        return Colors.orange;
      case 'discover':
        return Colors.green;
      case 'saved':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
