class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String? actionUrl;
  final String? imageUrl;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.actionUrl,
    required this.imageUrl,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = _toInt(json['id']);
    final userId = _toInt(json['userId']);

    if (id == null || userId == null) {
      throw const FormatException('Data notifikasi tidak valid');
    }

    return NotificationModel(
      id: id,
      userId: userId,
      title: _toText(json['title']),
      message: _toText(json['message']),
      type: _toText(json['type']).isEmpty ? 'info' : _toText(json['type']),
      actionUrl: _toOptionalText(json['actionUrl']),
      imageUrl: _toOptionalText(json['imageUrl']),
      readAt: _toOptionalText(json['readAt']),
      createdAt: _toOptionalText(json['createdAt']),
      updatedAt: _toOptionalText(json['updatedAt']),
    );
  }

  bool get isRead => readAt != null;

  NotificationModel copyWith({String? readAt}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      actionUrl: actionUrl,
      imageUrl: imageUrl,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) return null;
      return int.tryParse(normalized);
    }
    return null;
  }

  static String _toText(dynamic value) => value?.toString() ?? '';

  static String? _toOptionalText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
