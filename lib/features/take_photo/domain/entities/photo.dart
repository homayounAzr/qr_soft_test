/// The [Photo] entity to use it between layers.
class Photo {
  int? id;
  String directory;
  String name;
  int size;
  DateTime date;

  Photo({
    this.id,
    required this.directory,
    required this.name,
    required this.size,
    required this.date,
  });

  Map<String, dynamic> toMap() {

    return {
      'photo_directory': directory,
      'photo_name': name,
      'photo_date': date.toIso8601String(),
      'photo_size': size,
    };
  }

  static Photo fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['_id'],
      directory: map['photo_directory'],
      name: map['photo_name'],
      size: map['photo_size'],
      date: DateTime.parse(map['photo_date']),
    );
  }
}
