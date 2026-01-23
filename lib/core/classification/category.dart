enum CategoryId {
  productivity,
  physicalActivity,
  chores,
  health,
  social,
  general,
}

class CategoryMeta {
  final CategoryId id;
  final String label; // English only

  const CategoryMeta(this.id, this.label);
}

const kCategories = <CategoryMeta>[
  CategoryMeta(CategoryId.productivity, "Productivity"),
  CategoryMeta(CategoryId.physicalActivity, "Physical Activity"),
  CategoryMeta(CategoryId.chores, "Chores"),
  CategoryMeta(CategoryId.health, "Health"),
  CategoryMeta(CategoryId.social, "Social"),
  CategoryMeta(CategoryId.general, "General"),
];
