import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HealthTipsFilter {
  final String selectedCategory;
  final String searchQuery;

  HealthTipsFilter({this.selectedCategory = "All", this.searchQuery = ""});

  HealthTipsFilter copyWith({String? selectedCategory, String? searchQuery}) {
    return HealthTipsFilter(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HealthTipsFilterNotifier extends StateNotifier<HealthTipsFilter> {
  HealthTipsFilterNotifier() : super(HealthTipsFilter());

  void setCategory(String category) {
    logger.i("🔄 Setting health tips category to: $category");
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    logger.i("🔍 Updating health tips search query to: $query");
    // Debounce could be handled externally in the widget, but ensure lightweight updates
    state = state.copyWith(searchQuery: query);
  }
}

// Riverpod provider for filtering state
final healthTipsFilterProvider = StateNotifierProvider<HealthTipsFilterNotifier, HealthTipsFilter>(
  (ref) => HealthTipsFilterNotifier(),
);