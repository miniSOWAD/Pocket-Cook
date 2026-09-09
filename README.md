test/
├── helpers/
│   ├── test_app.dart
│   └── recipe_fixtures.dart
│
├── fakes/
│   ├── fake_auth_repository.dart
│   ├── fake_recipe_repository.dart
│   ├── fake_favorites_repository.dart
│   └── fake_grocery_repository.dart
│
├── app/
│   └── auth_guard_test.dart
│
├── features/
│   ├── auth/
│   │   ├── auth_provider_test.dart
│   │   └── login_screen_test.dart
│   │
│   ├── recipes/
│   │   ├── serving_calculator_test.dart
│   │   ├── recipe_search_provider_test.dart
│   │   ├── recipe_detail_provider_test.dart
│   │   └── recipe_card_test.dart
│   │
│   ├── favorites/
│   │   └── favorites_provider_test.dart
│   │
│   ├── profile/
│   │   └── profile_provider_test.dart
│   │
│   ├── settings/
│   │   └── settings_provider_test.dart
│   │
│   ├── cooking/
│   │   ├── cooking_timer_test.dart
│   │   └── cooking_provider_test.dart
│   │
│   ├── grocery_list/
│   │   ├── grocery_list_builder_test.dart
│   │   ├── ingredient_merger_test.dart
│   │   └── grocery_provider_test.dart
│   │
│   └── meal_planner/
│       └── meal_plan_provider_test.dart
│
└── core/
    └── input_validators_test.dart

integration_test/
├── browse_recipe_flow_test.dart
├── authentication_flow_test.dart
├── favorites_flow_test.dart
├── account_switching_test.dart
├── cooking_flow_test.dart
├── grocery_list_flow_test.dart
└── meal_planner_flow_test.dart
