class Succulent {
  final String id;
  final String name;
  final String? species;
  final String? description;
  final DateTime dateAdded;
  final String? imageUrl;
  final DateTime? lastWatered;
  final DateTime? lastFertilized;
  final DateTime? lastRepotted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Succulent({
    required this.id,
    required this.name,
    this.species,
    this.description,
    required this.dateAdded,
    this.imageUrl,
    this.lastWatered,
    this.lastFertilized,
    this.lastRepotted,
    required this.createdAt,
    required this.updatedAt,
  });

  Succulent copyWith({
    String? id,
    String? name,
    String? species,
    String? description,
    DateTime? dateAdded,
    String? imageUrl,
    DateTime? lastWatered,
    DateTime? lastFertilized,
    DateTime? lastRepotted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Succulent(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      description: description ?? this.description,
      dateAdded: dateAdded ?? this.dateAdded,
      imageUrl: imageUrl ?? this.imageUrl,
      lastWatered: lastWatered ?? this.lastWatered,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      lastRepotted: lastRepotted ?? this.lastRepotted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'description': description,
      'dateAdded': dateAdded.toIso8601String(),
      'imageUrl': imageUrl,
      'lastWatered': lastWatered?.toIso8601String(),
      'lastFertilized': lastFertilized?.toIso8601String(),
      'lastRepotted': lastRepotted?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Succulent.fromJson(Map<String, dynamic> json) {
    return Succulent(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String?,
      description: json['description'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      imageUrl: json['imageUrl'] as String?,
      lastWatered: json['lastWatered'] != null
          ? DateTime.parse(json['lastWatered'] as String)
          : null,
      lastFertilized: json['lastFertilized'] != null
          ? DateTime.parse(json['lastFertilized'] as String)
          : null,
      lastRepotted: json['lastRepotted'] != null
          ? DateTime.parse(json['lastRepotted'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Succulent(id: $id, name: $name, species: $species)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Succulent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
