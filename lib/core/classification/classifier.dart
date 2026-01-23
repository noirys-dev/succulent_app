import 'category.dart';
import 'dictionary_en.dart';

class ClassificationResult {
  final CategoryId category;
  final double confidence; // 0..1
  const ClassificationResult(this.category, this.confidence);
}

class Classifier {
  static List<String> _tokens(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static ClassificationResult classifyEn(String task) {
    final text = task.trim().toLowerCase();
    if (text.isEmpty) {
      return const ClassificationResult(CategoryId.general, 0.0);
    }

    final tokens = _tokens(text);
    final padded = " $text ";

    // CONTEXT RULE:
    // If user is explicitly "meeting" someone named "ted", treat it as Social,
    // not as the educational "TED" content brand.
    if (tokens.contains("meeting") && tokens.contains("ted")) {
      return const ClassificationResult(
        CategoryId.social,
        0.9,
      );
    }

    // HARD GUARD: Physical Activity always wins
    final paAnchors =
        DictionaryEn.anchors[CategoryId.physicalActivity] ?? const [];
    if (tokens.any((t) => paAnchors.contains(t))) {
      return const ClassificationResult(
        CategoryId.physicalActivity,
        0.95,
      );
    }

    final scores = <CategoryId, int>{
      for (final c in CategoryId.values) c: 0,
    };

    DictionaryEn.anchors.forEach((category, words) {
      for (final w in words) {
        final ww = w.toLowerCase().trim();

        final matched =
            ww.contains(" ") ? padded.contains(" $ww ") : tokens.contains(ww);

        if (matched) {
          scores[category] = (scores[category] ?? 0) + 3;
        }
      }
    });

    CategoryId best = CategoryId.general;
    int bestScore = 0;

    scores.forEach((category, score) {
      if (score > bestScore) {
        bestScore = score;
        best = category;
      }
    });

    final confidence = bestScore >= 3 ? 0.8 : 0.3;
    return ClassificationResult(best, confidence);
  }
}
