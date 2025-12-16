import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sakkeny_app/services/property_service.dart';
import 'package:sakkeny_app/models/cards.dart';

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final PropertyService _propertyService = PropertyService();

  Future<void> publishApartment() async {
  // ... your existing validation code ...

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // Get selected amenities
  List<String> selectedAmenitiesList = selectedAmenities.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  // Add property
  bool success = await _propertyService.addProperty(
    title: titleController.text.isEmpty 
        ? 'Modern Apartment' 
        : titleController.text,
    description: descriptionController.text,
    price: double.parse(rentController.text),
    location: PropertyLocation(
      city: cityController.text.isEmpty ? 'Cairo' : cityController.text,
      area: areaController.text.isEmpty ? 'Nasr City' : areaController.text,
      fullAddress: '${cityController.text.isEmpty ? 'Cairo' : cityController.text}, ${areaController.text.isEmpty ? 'Nasr City' : areaController.text}, Egypt',
    ),
    propertyType: selectedPropertyType,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    livingrooms: livingrooms,
    kitchens: kitchens,
    balconies: balconies,
    amenities: selectedAmenitiesList,
    imageFiles: selectedImages,
  );

  // Hide loading
  if (mounted) Navigator.pop(context);

  if (success) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Property published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // ✅ Return true to indicate success
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to publish property'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  final List<String> amenities = [
    "Air Conditioner",
    "In-unit Laundry",
    "Nearby Gym",
    "Elevator",
    "Doorman",
    "Nearby Garage",
    "Dishwasher",
    "Hardwood Floors",
    "Clothing Storage",
    "Wifi",
    "Kitchen",
    "Refrigerator",
    "Microwave",
    "Stove",
  ];

  final List<String> propertyTypes = [
    "Apartment",
    "Villa",
    "Studio",
    "Penthouse",
    "Duplex",
  ];

  Map<String, bool> selectedAmenities = {};
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  String selectedPropertyType = "Apartment";
  int bedrooms = 1;
  int bathrooms = 1;
  int livingrooms = 1;
  int kitchens = 1;
  int balconies = 0;

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
    for (var item in amenities) {
      selectedAmenities[item] = false;
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 100);

      if (images.isEmpty) return;

      setState(() {
        selectedImages.addAll(images.map((e) => File(e.path)));
      });
    } catch (e) {
      print("ERROR picking images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Add Your Apartment",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePickerSection(),
            const SizedBox(height: 20),

            // Title
            const Text("Title",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildTextBox(titleController, "e.g. Modern Apartment in Nasr City", maxLines: 1),

            const SizedBox(height: 20),

            // Description
            const Text("Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildTextBox(descriptionController, "Describe your apartment...", maxLines: 5),

            const SizedBox(height: 20),

            // Location Section
            const Text("Location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildLocationSection(),

            const SizedBox(height: 20),

            // Property Type Dropdown
            _buildInputWithLabel(
              "Property Type",
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: selectedPropertyType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: propertyTypes.map((String type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => selectedPropertyType = v!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rent
            _buildInputWithLabel(
              "Monthly Rent (EGP)",
              TextField(
                controller: rentController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "e.g. 3500",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rooms Grid
            const Text("Rooms",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDropdown("Bedrooms", bedrooms, (v) {
                  setState(() => bedrooms = v!);
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Bathrooms", bathrooms, (v) {
                  setState(() => bathrooms = v!);
                })),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown("Living Rooms", livingrooms, (v) {
                  setState(() => livingrooms = v!);
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Kitchens", kitchens, (v) {
                  setState(() => kitchens = v!);
                })),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown("Balconies", balconies, (v) {
                  setState(() => balconies = v!);
                }, max: 3)),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),

            const SizedBox(height: 25),

            // Amenities
            const Text("Amenities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _buildAmenitiesGrid(),

            const SizedBox(height: 30),

            // Publish Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276152),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: publishApartment,
                child: const Text(
                  "Publish Apartment",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Apartment Images",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: selectedImages.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276152),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        "+ Add Photos",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == selectedImages.length) {
                        return GestureDetector(
                          onTap: pickImages,
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF276152),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF276152),
                            ),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBox(controller, hint, {int maxLines = 5}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        TextField(
          controller: cityController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.location_city),
            hintText: "City (e.g. Cairo)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: areaController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.map),
            hintText: "Area (e.g. Nasr City)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputWithLabel(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDropdown(String label, int value, Function(int?) onChanged, {int max = 5}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: List.generate(
              max,
              (index) => DropdownMenuItem(
                value: index,
                child: Text("$index"),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: amenities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, i) {
        return CheckboxListTile(
          value: selectedAmenities[amenities[i]],
          onChanged: (v) {
            setState(() {
              selectedAmenities[amenities[i]] = v ?? false;
            });
          },
          title: Text(amenities[i]),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }
}