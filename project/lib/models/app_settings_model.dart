class AppSettingsModel {
  final int? id;
  final String key;
  final String value;
  final DateTime? updatedAt;

  AppSettingsModel({
    this.id,
    required this.key,
    required this.value,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      id: map['id'],
      key: map['key'],
      value: map['value'],
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }
}

