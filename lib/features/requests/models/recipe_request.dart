class RecipeRequest {
  const RecipeRequest({
    required this.id,
    required this.requesterUid,
    required this.requesterName,
    required this.requesterRole,
    required this.title,
    required this.details,
    required this.status,
    required this.createdAt,
    this.fulfilledRecipeId = '',
  });

  final String id;
  final String requesterUid;
  final String requesterName;
  final String requesterRole;
  final String title;
  final String details;
  final String status;
  final int createdAt;
  final String fulfilledRecipeId;

  bool get isPending => status == 'pending';

  factory RecipeRequest.fromJson(String id, Map<String, dynamic> json) => RecipeRequest(
        id: id,
        requesterUid: json['requesterUid'] as String? ?? '',
        requesterName: json['requesterName'] as String? ?? 'Visitor',
        requesterRole: json['requesterRole'] as String? ?? 'visitor',
        title: json['title'] as String? ?? 'Recipe request',
        details: json['details'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        fulfilledRecipeId: json['fulfilledRecipeId'] as String? ?? '',
      );
}
