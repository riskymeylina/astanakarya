class ConsultationRequestModel {
  final int id;
  final int buyerUserId;
  final String buyerName;
  final String? buyerPhone;
  final String? buyerEmail;
  final String? buyerWhatsapp;
  final int? propertyId;
  final String? propertyTitle;
  final String? propertyLocation;
  final String topic;
  final String preferredContactMethod;
  final String message;
  final String status;
  final String? staffNotes;
  final int? processedByUserId;
  final String? processedByName;
  final String? processedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? lastMessage;
  final String? lastMessageAt;
  final int? lastMessageSenderUserId;
  final String? lastMessageReadAt;
  final int unreadCount;

  // ===== SURVEY INTEGRATION =====
  final int? surveyId;
  final String? surveyStatus;
  final String? surveyDate;
  final String? surveyTime;

  const ConsultationRequestModel({
    required this.id,
    required this.buyerUserId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerEmail,
    required this.buyerWhatsapp,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.topic,
    required this.preferredContactMethod,
    required this.message,
    required this.status,
    required this.staffNotes,
    required this.processedByUserId,
    required this.processedByName,
    required this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageSenderUserId,
    required this.lastMessageReadAt,
    required this.unreadCount,

    // Survey
    required this.surveyId,
    required this.surveyStatus,
    required this.surveyDate,
    required this.surveyTime,
  });

  factory ConsultationRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final id = _toInt(json['id']);
    final buyerUserId = _toInt(json['buyerUserId']);

    if (id == null || buyerUserId == null) {
      throw const FormatException(
        'Data konsultasi tidak valid',
      );
    }

    return ConsultationRequestModel(
      id: id,
      buyerUserId: buyerUserId,
      buyerName: _toText(json['buyerName']),
      buyerPhone: _toOptionalText(json['buyerPhone']),
      buyerEmail: _toOptionalText(json['buyerEmail']),
      buyerWhatsapp: _toOptionalText(json['buyerWhatsapp']),
      propertyId: _toInt(json['propertyId']),
      propertyTitle: _toOptionalText(json['propertyTitle']),
      propertyLocation: _toOptionalText(
        json['propertyLocation'],
      ),
      topic: _toText(json['topic']),
      preferredContactMethod: _toText(
        json['preferredContactMethod'],
      ),
      message: _toText(json['message']),
      status: _toText(json['status']),
      staffNotes: _toOptionalText(json['staffNotes']),
      processedByUserId: _toInt(
        json['processedByUserId'],
      ),
      processedByName: _toOptionalText(
        json['processedByName'],
      ),
      processedAt: _toOptionalText(
        json['processedAt'],
      ),
      createdAt: _toOptionalText(
        json['createdAt'],
      ),
      updatedAt: _toOptionalText(
        json['updatedAt'],
      ),
      lastMessage: _toOptionalText(
        json['lastMessage'],
      ),
      lastMessageAt: _toOptionalText(
        json['lastMessageAt'],
      ),
      lastMessageSenderUserId: _toInt(
        json['lastMessageSenderUserId'],
      ),
      lastMessageReadAt: _toOptionalText(
        json['lastMessageReadAt'],
      ),
      unreadCount:
          _toInt(json['unreadCount']) ?? 0,

      // ===== SURVEY =====
      surveyId: _toInt(json['surveyId']),
      surveyStatus: _toOptionalText(
        json['surveyStatus'],
      ),
      surveyDate: _toOptionalText(
        json['surveyDate'],
      ),
      surveyTime: _toOptionalText(
        json['surveyTime'],
      ),
    );
  }

  bool get isPending =>
      status == 'pending';

  bool get isContacted =>
      status == 'contacted';

  bool get isResolved =>
      status == 'resolved';

  bool get isRejected =>
      status == 'rejected';

  // ===== SURVEY STATUS =====

  bool get hasSurvey =>
      surveyId != null;

  bool get surveyPending =>
      surveyStatus == 'pending';

  bool get surveyApproved =>
      surveyStatus == 'approved';

  bool get surveyCompleted =>
      surveyStatus == 'completed';

  bool get surveyRejected =>
      surveyStatus == 'rejected';

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final normalized =
          value.trim();

      if (normalized.isEmpty) {
        return null;
      }

      return int.tryParse(
        normalized,
      );
    }

    return null;
  }

  static String _toText(
    dynamic value,
  ) =>
      value?.toString() ?? '';

  static String? _toOptionalText(
    dynamic value,
  ) {
    final text =
        value?.toString().trim();

    if (text == null ||
        text.isEmpty ||
        text.toLowerCase() ==
            'null') {
      return null;
    }

    return text;
  }
}

class ConsultationChatMessageModel {
  final int id;
  final int consultationId;
  final int senderUserId;
  final String senderName;
  final String senderRole;
  final String messageType;
  final String message;
  final String? mediaUrl;
  final String? mediaName;
  final String? mediaMime;
  final String? createdAt;
  final String? readAt;

  const ConsultationChatMessageModel({
    required this.id,
    required this.consultationId,
    required this.senderUserId,
    required this.senderName,
    required this.senderRole,
    required this.messageType,
    required this.message,
    required this.mediaUrl,
    required this.mediaName,
    required this.mediaMime,
    required this.createdAt,
    required this.readAt,
  });

  factory ConsultationChatMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final id =
        ConsultationRequestModel._toInt(
      json['id'],
    );

    final consultationId =
        ConsultationRequestModel._toInt(
      json['consultationId'],
    );

    final senderUserId =
        ConsultationRequestModel._toInt(
      json['senderUserId'],
    );

    if (id == null ||
        consultationId == null ||
        senderUserId == null) {
      throw const FormatException(
        'Data chat konsultasi tidak valid',
      );
    }

    return ConsultationChatMessageModel(
      id: id,
      consultationId: consultationId,
      senderUserId: senderUserId,
      senderName:
          ConsultationRequestModel._toText(
        json['senderName'],
      ),
      senderRole:
          ConsultationRequestModel._toText(
        json['senderRole'],
      ),
      messageType:
          ConsultationRequestModel._toText(
        json['messageType'],
      ),
      message:
          ConsultationRequestModel._toText(
        json['message'],
      ),
      mediaUrl:
          ConsultationRequestModel._toOptionalText(
        json['mediaUrl'],
      ),
      mediaName:
          ConsultationRequestModel._toOptionalText(
        json['mediaName'],
      ),
      mediaMime:
          ConsultationRequestModel._toOptionalText(
        json['mediaMime'],
      ),
      createdAt:
          ConsultationRequestModel._toOptionalText(
        json['createdAt'],
      ),
      readAt:
          ConsultationRequestModel._toOptionalText(
        json['readAt'],
      ),
    );
  }
}
