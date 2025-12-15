import 'package:flutter/material.dart';
import './AddApartmentPage.dart';

class Apartment {
  final String id;
  final String title;
  final String location;
  final int price;
  final bool isAvailable;

  Apartment({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    this.isAvailable = true,
  });
}

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final List<Apartment> apartments = [
    Apartment(
      id: "1",
      title: "Modern Apartment",
      location: "Nasr City",
      price: 3500,
    ),
    Apartment(
      id: "2",
      title: "Cozy Studio",
      location: "Maadi",
      price: 2800,
      isAvailable: false,
    ),
    Apartment(
      id: "3",
      title: "Room for Rent",
      location: "Heliopolis",
      price: 2000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "My Listings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: apartments.isEmpty
                ? _emptyState()
                : _gridListings(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF276152),
        foregroundColor: Colors.white,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddApartmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /* ================= PROFILE HEADER ================= */

  Widget _profileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mohamed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "My Apartments",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ================= GRID ================= */

  Widget _gridListings() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: apartments.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        final apartment = apartments[index];
        return _apartmentCard(apartment, index);
      },
    );
  }

  /* ================= CARD ================= */

  Widget _apartmentCard(Apartment apartment, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Navigator.push to PropertyDetailsPage
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(Icons.home, size: 40, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    apartment.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${apartment.price} EGP",
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      _statusChip(apartment.isAvailable),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          // Edit Apartment
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        onPressed: () {
                          _deleteApartment(index);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= HELPERS ================= */

  Widget _statusChip(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        available ? "Available" : "Rented",
        style: TextStyle(
          fontSize: 11,
          color: available ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _deleteApartment(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Apartment"),
        content: const Text("Are you sure you want to delete this apartment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                apartments.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No apartments added yet",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}