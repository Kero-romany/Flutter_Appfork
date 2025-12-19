import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sakkeny_app/services/property_service.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final PropertyService _propertyService = PropertyService();
  final SupabaseClient supabase = Supabase.instance.client;

  /* ---------------- Controllers ---------------- */
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  /* ---------------- Data ---------------- */
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  final List<String> amenities = [
    "Air Conditioning",
    "Wifi",
    "Closet",
    "Iron",
    "TV",
    "Dedicated Workspace",
  ];



  Map<String, bool> selectedAmenities = {};

  int bedrooms = 1;
  int bathrooms = 1;
  int kitchens = 1;     // ✅ VISIBLE INPUT
  int balconies = 0;    // ✅ VISIBLE INPUT

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    for (var item in amenities) {
      selectedAmenities[item] = false;
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    rentController.dispose();
    titleController.dispose();
    cityController.dispose();
    areaController.dispose();
    super.dispose();
  }

  /* ---------------- Image Picker ---------------- */
  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 90);
    if (images.isEmpty) return;

    setState(() {
      selectedImages.addAll(images);
    });
  }

  /* ---------------- Upload Images to Supabase ---------------- */
  Future<List<String>> uploadImagesToSupabase() async {
    List<String> imageUrls = [];
    final uuid = const Uuid();

    for (final image in selectedImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}.jpg';

      Uint8List bytes = await image.readAsBytes();

      await supabase.storage
          .from('apartment-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = supabase.storage
          .from('apartment-images')
          .getPublicUrl(fileName);

      imageUrls.add(publicUrl);
    }

    return imageUrls;
  }

  /* ---------------- Publish Apartment ---------------- */
  Future<void> publishApartment() async {
    // ✅ Validation
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please add at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (cityController.text.trim().isEmpty || areaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter city and area'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (rentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter monthly rent'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uploadedImageUrls = await uploadImagesToSupabase();

      List<String> selectedAmenitiesList = selectedAmenities.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      bool success = await _propertyService.addProperty(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(rentController.text) ?? 0,
        location: PropertyLocation(
          city: cityController.text.trim(),
          area: areaController.text.trim(),
          fullAddress: '${cityController.text.trim()}, ${areaController.text.trim()}, Egypt',
        ),
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        kitchens: kitchens,       // ✅ SENT TO SERVICE
        balconies: balconies,     // ✅ SENT TO SERVICE
        amenities: selectedAmenitiesList,
        imageUrls: uploadedImageUrls,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Property published successfully!'
                  : '❌ Failed to publish property',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /* ---------------- Image Widget (Web + Mobile) ---------------- */
  Widget buildImage(XFile image) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Image.memory(
            snapshot.data!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.file(
        File(image.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
  }

  /* ---------------- UI ---------------- */
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
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF276152)),
                  SizedBox(height: 16),
                  Text('Uploading property...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePickerSection(),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Title",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _buildTextBox(
                    titleController,
                    "e.g. Modern Apartment in Nasr City",
                    maxLines: 1,
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _buildTextBox(
                    descriptionController,
                    "Describe your apartment...",
                    maxLines: 5,
                  ),

                  const SizedBox(height: 20),

                  // Location
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _buildLocationSection(),

                  const SizedBox(height: 20),

                  // Rent
                  const SizedBox(height: 20),
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

                  // ✅ ROOMS SECTION - UPDATED WITH KITCHENS & BALCONIES
                  const Text(
                    "Rooms",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  
                  // Bedrooms
                  const Text("Bedrooms", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      5,
                      (i) => _buildNumberChip(i + 1, bedrooms, (v) => setState(() => bedrooms = v)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bathrooms
                  const Text("Bathrooms", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      3,
                      (i) => _buildNumberChip(i + 1, bathrooms, (v) => setState(() => bathrooms = v)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ✅ KITCHENS - NEW INPUT
                  const Text("Kitchens", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      3,
                      (i) => _buildNumberChip(i + 1, kitchens, (v) => setState(() => kitchens = v)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ BALCONIES - NEW INPUT (starts from 0)
                  const Text("Balconies", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: List.generate(
                      4,
                      (i) => _buildNumberChip(i, balconies, (v) => setState(() => balconies = v)),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Amenities
                  const Text(
                    "Amenities",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /* ---------------- Image Picker UI ---------------- */
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
                              border: Border.all(color: const Color(0xFF276152)),
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
                            child: buildImage(selectedImages[index]),
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
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
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

  /* ---------------- Helpers ---------------- */
  Widget _buildTextBox(
    TextEditingController controller,
    String hint, {
    int maxLines = 5,
  }) {
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildNumberChip(int number, int selected, Function(int) onSelect) {
    final bool isSelected = selected == number;
    return ChoiceChip(
      showCheckmark: true,
      checkmarkColor: Colors.white,
      label: Text(
        number.toString(),
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF276152),
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelect(number),
    );
  }

  Widget _buildAmenitiesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: amenities.map((a) {
        return CheckboxListTile(
          value: selectedAmenities[a],
          activeColor: const Color(0xFF276152),
          checkColor: Colors.white,
          title: Text(a),
          onChanged: (v) {
            setState(() {
              selectedAmenities[a] = v!;
            });
          },
        );
      }).toList(),
    );
  }
}