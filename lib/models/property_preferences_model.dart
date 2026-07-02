class PropertyPreferencesModel {
  final List<String> preferredCategories;
  final String preferredLocation;
  final int? minPrice;
  final int? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final int? minBuildingArea;
  final int? minLandArea;
  final String notes;

  const PropertyPreferencesModel({
    required this.preferredCategories,
    required this.preferredLocation,
    required this.minPrice,
    required this.maxPrice,
    required this.minBedrooms,
    required this.minBathrooms,
    required this.minBuildingArea,
    required this.minLandArea,
    required this.notes,
  });

  const PropertyPreferencesModel.empty()
    : preferredCategories = const [],
      preferredLocation = '',
      minPrice = null,
      maxPrice = null,
      minBedrooms = null,
      minBathrooms = null,
      minBuildingArea = null,
      minLandArea = null,
      notes = '';

  factory PropertyPreferencesModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['preferredCategories'];
    final preferredCategories = rawCategories is List
        ? rawCategories
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    return PropertyPreferencesModel(
      preferredCategories: preferredCategories,
      preferredLocation: _toText(json['preferredLocation']),
      minPrice: _toInt(json['minPrice']),
      maxPrice: _toInt(json['maxPrice']),
      minBedrooms: _toInt(json['minBedrooms']),
      minBathrooms: _toInt(json['minBathrooms']),
      minBuildingArea: _toInt(json['minBuildingArea']),
      minLandArea: _toInt(json['minLandArea']),
      notes: _toText(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCategories': preferredCategories,
      'preferredLocation': preferredLocation,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minBedrooms': minBedrooms,
      'minBathrooms': minBathrooms,
      'minBuildingArea': minBuildingArea,
      'minLandArea': minLandArea,
      'notes': notes,
    };
  }

  PropertyPreferencesModel copyWith({
    List<String>? preferredCategories,
    String? preferredLocation,
    int? minPrice,
    int? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    int? minBuildingArea,
    int? minLandArea,
    String? notes,
  }) {
    return PropertyPreferencesModel(
      preferredCategories: preferredCategories ?? this.preferredCategories,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      minBuildingArea: minBuildingArea ?? this.minBuildingArea,
      minLandArea: minLandArea ?? this.minLandArea,
      notes: notes ?? this.notes,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return int.tryParse(text);
  }

  static String _toText(dynamic value) {
    final text = value?.toString() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }
}
