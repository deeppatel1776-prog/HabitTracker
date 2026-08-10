import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HabitSortOption { newest, oldest, streak, name }
enum HabitFilterStatus { all, active, completed, archived }

class HabitFilterState {
  final String searchQuery;
  final String? selectedCategory;
  final HabitFilterStatus filterStatus;
  final HabitSortOption sortOption;

  HabitFilterState({
    this.searchQuery = '',
    this.selectedCategory,
    this.filterStatus = HabitFilterStatus.active,
    this.sortOption = HabitSortOption.newest,
  });

  HabitFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    HabitFilterStatus? filterStatus,
    HabitSortOption? sortOption,
  }) {
    return HabitFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      filterStatus: filterStatus ?? this.filterStatus,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class HabitFilterNotifier extends StateNotifier<HabitFilterState> {
  HabitFilterNotifier() : super(HabitFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String? categoryId) {
    if (state.selectedCategory == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: categoryId);
    }
  }

  void setFilterStatus(HabitFilterStatus status) {
    state = state.copyWith(filterStatus: status);
  }

  void setSortOption(HabitSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void resetFilters() {
    state = HabitFilterState();
  }
}

final habitFilterProvider =
    StateNotifierProvider<HabitFilterNotifier, HabitFilterState>((ref) {
  return HabitFilterNotifier();
});
