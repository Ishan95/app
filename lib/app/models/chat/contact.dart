class Contact {
  String id;
  String? name;
  String? role;
  String? profileImage;
  String? status;

  Contact({required this.id, required this.name, required this.role, this.profileImage, this.status = 'active'});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String?,
      status: json['status'] as String,
    );
  }
}
