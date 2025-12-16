import 'package:flutter/material.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/pages/property.dart';
import 'package:sakkeny_app/pages/property_card.dart';

class PropertySearchPage extends StatefulWidget {
  final List<PropertyModel> properties;

  const PropertySearchPage({super.key, required this.properties});

  @override
  State<PropertySearchPage> createState() => _PropertySearchPageState();
}

class _PropertySearchPageState extends State<PropertySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PropertyModel> _searchResults = [];
  List<PropertyModel> _recentSearches = [];

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _searchResults = widget.properties.where((property) {
        final q = query.toLowerCase();
        return property.title.toLowerCase().contains(q) ||
            property.location.fullAddress.toLowerCase().contains(q) ||
            property.location.city.toLowerCase().contains(q) ||
            property.location.area.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _addToRecent(PropertyModel property) {
    _recentSearches.removeWhere(
        (p) => p.propertyId == property.propertyId);
    _recentSearches.insert(0, property);
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by city, street, title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildResults()
                : _buildRecent(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No properties found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (_, index) {
        final property = _searchResults[index];
        return GestureDetector(
          onTap: () {
            _addToRecent(property);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailsPage(property: property),
              ),
            );
          },
          child: PropertyCard(
            price: property.priceDisplay,
            title: property.title,
            location: property.location.fullAddress,
            imagePath: property.mainImage,
            propertyId: property.propertyId,
          ),
        );
      },
    );
  }

  Widget _buildRecent() {
    if (_recentSearches.isEmpty) {
      return const Center(child: Text('No recent searches'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSearches.length,
      itemBuilder: (_, index) {
        final property = _recentSearches[index];
        return ListTile(
          title: Text(property.title),
          subtitle: Text(property.location.fullAddress),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PropertyDetailsPage(property: property),
              ),
            );
          },
        );
      },
    );
  }
}
