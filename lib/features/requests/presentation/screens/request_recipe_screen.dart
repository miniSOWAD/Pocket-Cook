import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../providers/request_provider.dart';

class RequestRecipeScreen extends StatefulWidget {
  const RequestRecipeScreen({super.key});

  @override
  State<RequestRecipeScreen> createState() => _RequestRecipeScreenState();
}

class _RequestRecipeScreenState extends State<RequestRecipeScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _details = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final requests = context.read<RequestProvider>();
    final ok = await requests.requestRecipe(_title.text, _details.text);
    if (!mounted) return;
    if (ok) {
      _title.clear();
      _details.clear();
      showMessage(context, 'Recipe request sent to the cooks and admin.');
    } else {
      showMessage(context, requests.errorMessage ?? 'Could not send the request.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Request a recipe')),
      body: SafeArea(
        child: FeaturePage(
          title: 'What would you love to cook?',
          subtitle: 'Send a recipe idea to the cooks and admin. You can follow the status of every request here.',
          eyebrow: 'Recipe wishes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorNotice(requests.errorMessage),
              SurfaceCard(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _title,
                        maxLength: 120,
                        validator: (value) => (value ?? '').trim().length < 2 ? 'Enter the recipe you want.' : null,
                        decoration: const InputDecoration(
                          labelText: 'Recipe name',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _details,
                        maxLength: 600,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Anything specific? (optional)',
                          hintText: 'For example: spicy, vegetarian, Bangladeshi style...',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Send request',
                        icon: Icons.send_rounded,
                        loading: requests.busy,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const SectionHeading('Your requests'),
              if (requests.myRecipeRequests.isEmpty)
                const EmptyStateView(
                  title: 'No requests yet',
                  message: 'When you ask for a recipe, its progress will appear here.',
                )
              else
                for (final request in requests.myRecipeRequests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(request.title, style: Theme.of(context).textTheme.titleMedium),
                                if (request.details.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(request.details),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Chip(label: Text(request.status.toUpperCase())),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
