import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../accounts/models/app_account.dart';
import '../../../recipes/models/ingredient.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/models/recipe_category.dart';
import '../../../recipes/models/recipe_step.dart';

class RecipeEditorResult {
  const RecipeEditorResult(this.recipe, {this.fulfilledRequestId});
  final Recipe recipe;
  final String? fulfilledRequestId;
}

Future<RecipeEditorResult?> showRecipeEditor(
  BuildContext context, {
  required AppAccount account,
  required List<RecipeCategory> categories,
  Recipe? recipe,
  String? requestedTitle,
  String? requestedDetails,
  String? requestId,
}) =>
    showDialog<RecipeEditorResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RecipeEditorDialog(
        account: account,
        categories: categories,
        recipe: recipe,
        requestedTitle: requestedTitle,
        requestedDetails: requestedDetails,
        requestId: requestId,
      ),
    );

class _RecipeEditorDialog extends StatefulWidget {
  const _RecipeEditorDialog({
    required this.account,
    required this.categories,
    this.recipe,
    this.requestedTitle,
    this.requestedDetails,
    this.requestId,
  });

  final AppAccount account;
  final List<RecipeCategory> categories;
  final Recipe? recipe;
  final String? requestedTitle;
  final String? requestedDetails;
  final String? requestId;

  @override
  State<_RecipeEditorDialog> createState() => _RecipeEditorDialogState();
}

class _RecipeEditorDialogState extends State<_RecipeEditorDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController prep;
  late final TextEditingController cook;
  late final TextEditingController servings;
  late final TextEditingController imageUrl;
  late final TextEditingController tags;
  late final TextEditingController ingredients;
  late final TextEditingController steps;
  late String categoryId;
  late String difficulty;
  late bool vegetarian;
  late bool featured;
  late bool published;

  static const units = {'', 'pcs', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup'};

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    title = TextEditingController(text: recipe?.title ?? widget.requestedTitle ?? '');
    description = TextEditingController(text: recipe?.description ?? widget.requestedDetails ?? '');
    prep = TextEditingController(text: '${recipe?.prepMinutes ?? 10}');
    cook = TextEditingController(text: '${recipe?.cookMinutes ?? 20}');
    servings = TextEditingController(text: '${recipe?.baseServings ?? 2}');
    imageUrl = TextEditingController(text: recipe?.imageUrl ?? '');
    tags = TextEditingController(text: recipe?.tags.join(', ') ?? '');
    ingredients = TextEditingController(
      text: recipe?.ingredients
              .map((item) => '${item.name} | ${item.quantity ?? ''} | ${item.unit} | ${item.note}')
              .join('\n') ??
          '',
    );
    steps = TextEditingController(
      text: recipe?.steps
              .map((step) => '${step.title} | ${step.instruction} | ${step.timerSeconds}')
              .join('\n') ??
          '',
    );
    categoryId = recipe?.categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first.id : 'dinner');
    difficulty = recipe?.difficulty ?? 'Easy';
    vegetarian = recipe?.vegetarian ?? false;
    featured = recipe?.featured ?? false;
    published = recipe?.isPublished ?? true;
  }

  @override
  void dispose() {
    for (final controller in [title, description, prep, cook, servings, imageUrl, tags, ingredients, steps]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Ingredient> _parseIngredients() {
    final result = <Ingredient>[];
    final lines = ingredients.text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty);
    var index = 0;
    for (final line in lines) {
      final parts = line.split('|').map((part) => part.trim()).toList();
      if (parts.isEmpty || parts[0].isEmpty) throw const FormatException('Every ingredient needs a name.');
      final quantityText = parts.length > 1 ? parts[1] : '';
      final quantity = quantityText.isEmpty ? null : double.tryParse(quantityText);
      if (quantityText.isNotEmpty && (quantity == null || quantity <= 0)) {
        throw FormatException('Invalid quantity for ${parts[0]}.');
      }
      final unit = parts.length > 2 ? parts[2].toLowerCase() : '';
      if (!units.contains(unit)) throw FormatException('Unsupported unit "$unit" for ${parts[0]}.');
      final idBase = parts[0].toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      result.add(Ingredient(
        id: idBase.isEmpty ? 'ingredient-$index' : '$idBase-$index',
        name: parts[0],
        quantity: quantity,
        unit: unit,
        note: parts.length > 3 ? parts.sublist(3).join(' | ') : '',
      ));
      index++;
    }
    if (result.isEmpty) throw const FormatException('Add at least one ingredient.');
    return result;
  }

  List<RecipeStep> _parseSteps() {
    final result = <RecipeStep>[];
    final lines = steps.text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty);
    for (final line in lines) {
      final parts = line.split('|').map((part) => part.trim()).toList();
      if (parts.length < 2 || parts[0].isEmpty || parts[1].isEmpty) {
        throw const FormatException('Each step needs a title and instruction.');
      }
      final seconds = parts.length > 2 && parts[2].isNotEmpty ? int.tryParse(parts[2]) : 0;
      if (seconds == null || seconds < 0 || seconds > 86400) throw FormatException('Invalid timer for ${parts[0]}.');
      result.add(RecipeStep(title: parts[0], instruction: parts[1], timerSeconds: seconds));
    }
    if (result.isEmpty) throw const FormatException('Add at least one cooking step.');
    return result;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final existing = widget.recipe;
      final recipe = Recipe(
        id: existing?.id ?? const Uuid().v4(),
        title: title.text.trim(),
        description: description.text.trim(),
        categoryId: categoryId,
        prepMinutes: int.parse(prep.text),
        cookMinutes: int.parse(cook.text),
        baseServings: int.parse(servings.text),
        ingredients: _parseIngredients(),
        steps: _parseSteps(),
        imageAsset: existing?.imageAsset ?? 'assets/images/recipes/bowl.png',
        imageUrl: imageUrl.text.trim(),
        difficulty: difficulty,
        vegetarian: vegetarian,
        featured: featured,
        isPublished: published,
        tags: tags.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        createdByUid: existing?.createdByUid ?? widget.account.uid,
        cookName: existing?.cookName ?? widget.account.displayName,
        createdAt: existing?.createdAt == 0 || existing == null ? now : existing.createdAt,
        updatedAt: now,
      );
      Navigator.pop(context, RecipeEditorResult(recipe, fulfilledRequestId: widget.requestId));
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  String? _required(String? value) => (value ?? '').trim().isEmpty ? 'Required.' : null;
  String? _number(String? value, int min, int max) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number < min || number > max) return 'Use $min-$max.';
    return null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.recipe == null ? 'Add recipe' : 'Edit recipe'),
        content: SizedBox(
          width: 780,
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(controller: title, validator: _required, maxLength: 120, decoration: const InputDecoration(labelText: 'Recipe title')),
                  const SizedBox(height: 10),
                  TextFormField(controller: description, validator: _required, minLines: 2, maxLines: 4, maxLength: 1000, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: categoryId,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: widget.categories.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))).toList(),
                        onChanged: (value) => setState(() => categoryId = value ?? categoryId),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: difficulty,
                        decoration: const InputDecoration(labelText: 'Difficulty'),
                        items: const ['Easy', 'Medium', 'Hard'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                        onChanged: (value) => setState(() => difficulty = value ?? difficulty),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextFormField(controller: prep, validator: (v) => _number(v, 0, 1440), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prep minutes'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: cook, validator: (v) => _number(v, 0, 1440), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cook minutes'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: servings, validator: (v) => _number(v, 1, 12), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Servings'))),
                  ]),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: imageUrl,
                    decoration: const InputDecoration(labelText: 'Image URL (HTTPS, optional)'),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return null;
                      return text.startsWith('https://') ? null : 'Use an HTTPS image URL.';
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(controller: tags, decoration: const InputDecoration(labelText: 'Tags', hintText: 'quick, curry, family')),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ingredients,
                    minLines: 5,
                    maxLines: 9,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients - one per line',
                      hintText: 'Chicken | 500 | g | cubed\nSalt |  |  | to taste',
                      helperText: 'Format: name | quantity | unit | note. Units: pcs, g, kg, ml, l, tsp, tbsp, cup.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: steps,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Cooking steps - one per line',
                      hintText: 'Prepare | Chop the vegetables. | 0\nSimmer | Cook gently. | 600',
                      helperText: 'Format: step title | instruction | timer seconds.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilterChip(label: const Text('Vegetarian'), selected: vegetarian, onSelected: (value) => setState(() => vegetarian = value)),
                      FilterChip(label: const Text('Featured'), selected: featured, onSelected: (value) => setState(() => featured = value)),
                      FilterChip(label: const Text('Published'), selected: published, onSelected: (value) => setState(() => published = value)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save recipe')),
        ],
      );
}
