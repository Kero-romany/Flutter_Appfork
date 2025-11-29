import 'package:flutter/material.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/property.dart';

class PropertySearchPage extends StatefulWidget {
  final List<PropertyModel> properties;

  const PropertySearchPage({Key? key, required this.properties})
      : super(key: key);

  @override
  State<PropertySearchPage> createState() => _PropertySearchPageState();
}

class _PropertySearchPageState extends State<PropertySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<PropertyModel> _searchResults;

  // Add a list to store recent searches
  List<PropertyModel> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchResults = []; // Initially empty, show recent searches instead
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = widget.properties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
            property.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _addToRecent(PropertyModel property) {
    setState(() {
      _recentSearches.removeWhere((p) => p.title == property.title); // avoid duplicates
      _recentSearches.insert(0, property); // add to top
      if (_recentSearches.length > 5) _recentSearches.removeLast(); // keep last 5
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text('Search Properties',
            style: TextStyle(color: Colors.black54, fontSize: 14)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isSearching
                ? (_searchResults.isEmpty ? _buildEmptyState() : _buildSearchGrid())
                : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by city, street, or title...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              FocusScope.of(context).unfocus();
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF386B5D))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Properties Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Try searching for another city or street'),
        ],
      ),
    );
  }

  Widget _buildSearchGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final property = _searchResults[index];
        return GestureDetector(
          onTap: () {
            _addToRecent(property); // add to recent searches
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsPage(
                  price: property.price,
                  title: property.title,
                  location: property.location,
                  image: property.image,
                  description: property.description,
                  isWifi: property.isWifi,
                  Livingroom: property.Livingroom,
                  bedroom: property.bedroom,
                  bathroom: property.bathroom,
                  balcony: property.balcony,
                  kitchen: property.kitchen,
                  rating: property.rating,
                  reviews: property.reviews,
                ),
              ),
            );
          },
          child: PropertyCard(
            price: property.price,
            title: property.title,
            location: property.location,
            imagePath: property.image,
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text(
          'No Recent Searches',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final property = _recentSearches[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(property.image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          title: Text(property.title),
          subtitle: Text(property.location),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _recentSearches.removeAt(index));
            },
          ),
          onTap: () {
            _addToRecent(property);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsPage(
                  price: property.price,
                  title: property.title,
                  location: property.location,
                  image: property.image,
                  description: property.description,
                  isWifi: property.isWifi,
                  Livingroom: property.Livingroom,
                  bedroom: property.bedroom,
                  bathroom: property.bathroom,
                  balcony: property.balcony,
                  kitchen: property.kitchen,
                  rating: property.rating,
                  reviews: property.reviews,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
