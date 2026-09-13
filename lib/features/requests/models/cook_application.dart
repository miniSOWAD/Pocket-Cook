class CookApplication {
  const CookApplication({
    required this.id,
    required this.uid,
    required this.requesterName,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
  });

  final String id;
  final String uid;
  final String requesterName;
  final String message;
  final String status;
  final int createdAt;
  final int? reviewedAt;

  bool get isPending => status == 'pending';

  factory CookApplication.fromJson(String id, Map<String, dynamic> json) => CookApplication(
        id: id,
        uid: json['uid'] as String? ?? id,
        requesterName: json['requesterName'] as String? ?? 'Visitor',
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        reviewedAt: (json['reviewedAt'] as num?)?.toInt(),
      );
}
