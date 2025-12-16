class PropertyModel {
  final String propertyId;
  final String userId;
  final String userName;
  final String? userImage;
  
  // Property Details
  final String title;
  final String description;
  final double price; // Changed from String to double
  final String priceDisplay; // Keep for UI: "EGP7,000 /Month"
  
  // Location (structured)
  final PropertyLocation location;
  
  // Property Type & Features
  final String propertyType; // "Apartment"|"Bungalow"|"Duplex"|"Villa"
  final int bedrooms;
  final int bathrooms;
  final int livingrooms;
  final int kitchens;
  final int balconies;
  
  // Amenities
  final List<String> amenities;
  final bool isWifi;
  
  // Images
  final List<String> images;
  final String mainImage;
  
  // Ratings
  final double rating;
  final int reviews;
  
  // Status
  final String status; // "available"|"rented"|"pending"
  final bool isPublished;
  
 

  PropertyModel({
    required this.propertyId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.title,
    required this.description,
    required this.price,
    required this.priceDisplay,
    required this.location,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    this.livingrooms = 1,
    this.kitchens = 1,
    this.balconies = 0,
    required this.amenities,
    required this.isWifi,
    required this.images,
    required this.mainImage,
    this.rating = 0.0,
    this.reviews = 0,
    this.status = 'available',
    this.isPublished = true,

  });

  // ✅ Convert from Firestore
  factory PropertyModel.fromFirestore(Map<String, dynamic> data) {
    return PropertyModel(
      propertyId: data['propertyId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userImage: data['userImage'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      priceDisplay: data['priceDisplay'] ?? '',
      location: PropertyLocation.fromMap(data['location'] ?? {}),
      propertyType: data['propertyType'] ?? 'Apartment',
      bedrooms: data['bedrooms'] ?? 1,
      bathrooms: data['bathrooms'] ?? 1,
      livingrooms: data['livingrooms'] ?? 1,
      kitchens: data['kitchens'] ?? 1,
      balconies: data['balconies'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      isWifi: data['isWifi'] ?? false,
      images: List<String>.from(data['images'] ?? []),
      mainImage: data['mainImage'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      status: data['status'] ?? 'available',
      isPublished: data['isPublished'] ?? true,

    );
  }

  // ✅ Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'title': title,
      'description': description,
      'price': price,
      'priceDisplay': priceDisplay,
      'location': location.toMap(),
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'livingrooms': livingrooms,
      'kitchens': kitchens,
      'balconies': balconies,
      'amenities': amenities,
      'isWifi': isWifi,
      'images': images,
      'mainImage': mainImage,
      'rating': rating,
      'reviews': reviews,
      'status': status,
      'isPublished': isPublished,

    };
  }

  // ✅ Backward compatibility - keeps your old PropertyModel constructor working
  factory PropertyModel.legacy({
    required String price,
    required String title,
    required String location,
    required String image,
    required String description,
    required bool isWifi,
    required int Livingroom,
    required int bedroom,
    required int bathroom,
    required int balcony,
    required int kitchen,
    required double rating,
    required int reviews,
  }) {
    return PropertyModel(
      propertyId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'temp_user',
      userName: 'user',
      title: title,
      description: description,
      price: double.tryParse(price.replaceAll(',', '')) ?? 0,
      priceDisplay: 'EGP$price /Month',
      location: PropertyLocation(
        city: location.split(',').first.trim(),
        area: location.split(',').length > 1 ? location.split(',')[1].trim() : '',
        fullAddress: location,
      ),
      propertyType: 'Apartment',
      bedrooms: bedroom,
      bathrooms: bathroom,
      livingrooms: Livingroom,
      kitchens: kitchen,
      balconies: balcony,
      amenities: isWifi ? ['Wifi'] : [],
      isWifi: isWifi,
      images: [image],
      mainImage: image,
      rating: rating,
      reviews: reviews,

    );
  }
}

// ✅ Location Model
class PropertyLocation {
  final String city;
  final String area;
  final String? street;
  final String fullAddress;
  final double? latitude;
  final double? longitude;

  PropertyLocation({
    required this.city,
    required this.area,
    this.street,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });

  factory PropertyLocation.fromMap(Map<String, dynamic> map) {
    return PropertyLocation(
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      street: map['street'],
      fullAddress: map['fullAddress'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'area': area,
      'street': street,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}