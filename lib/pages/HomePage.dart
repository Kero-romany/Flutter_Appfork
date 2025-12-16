import 'package:flutter/material.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/pages/property_card.dart';
import 'package:sakkeny_app/services/property_service.dart';
import 'package:sakkeny_app/pages/AddApartmentPage.dart';
import 'package:sakkeny_app/pages/FilterPage.dart';
import 'package:sakkeny_app/pages/SearchPage.dart';
import 'package:sakkeny_app/pages/property.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _allProperties = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF276152),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddApartmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ================= TOP SECTION =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Location',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Color(0xFF276152)),
                              SizedBox(width: 4),
                              Text(
                                'Feryal Street, Assiut',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// ================= SEARCH =================
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_allProperties.isEmpty) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertySearchPage(
                                  properties: _allProperties,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 12),
                                Text(
                                  'Search by city, street...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FilterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Header
                  const Text(
                    'Recommended Property',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            /// ================= PROPERTIES =================
            Expanded(
              child: StreamBuilder<List<PropertyModel>>(
                stream: _propertyService.getAllProperties(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No properties available'));
                  }

                  _allProperties = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _allProperties.length,
                    itemBuilder: (context, index) {
                      final property = _allProperties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailsPage(
                                property: property,
                              ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
