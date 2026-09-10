class RecipeStep {
  const RecipeStep({required this.title, required this.instruction, this.timerSeconds = 0});
  final String title;
  final String instruction;
  final int timerSeconds;
  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    final result = RecipeStep(
    title: json['title'] as String, instruction: json['instruction'] as String,
    timerSeconds: (json['timerSeconds'] as num?)?.toInt() ?? 0);
    if (result.title.trim().isEmpty || result.instruction.trim().isEmpty ||
        result.timerSeconds < 0 || result.timerSeconds > 86400) {
      throw const FormatException('Invalid recipe instruction.');
    }
    return result;
  }
  Map<String, dynamic> toJson() => {'title': title, 'instruction': instruction, 'timerSeconds': timerSeconds};
}
