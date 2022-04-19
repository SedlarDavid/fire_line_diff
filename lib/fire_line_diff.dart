library fire_line_diff;

/// Enum that reflects changes of items
/// [positive] - items were added
/// [negative] - items were removed
/// [neutral] - no changes
enum LineDiffState { positive, neutral, negative }

/// Class containing result [LineDiffState] and compared items
class ItemResult<LeftItem, RightItem> {
  final LineDiffState state;

  final LeftItem left;
  final RightItem right;

  const ItemResult(this.left, this.right, {this.state = LineDiffState.neutral});
}

/// Main class containing methods responsible for diff handling
///
/// use [FireLineDiff.diff(leftItems, rightItems)]
class FireLineDiff<LeftItem, RightItem> {
  /// Method comparing two objects by converting them into strings
  /// These strings are compared line by line and
  ///
  /// [ItemResult] contains diff state and compared items
  static List<ItemResult<LeftType?, RightType?>> diff<LeftType, RightType>(
      List<LeftType> leftItems, List<RightType> rightItems) {
    final commonSeq = _longestCommonSubstring(
        leftItems.map((e) => e.toString().split('')).toList(growable: false),
        rightItems.map((e) => e.toString().split('')).toList(growable: false));
    final startBefore = commonSeq.startString1;
    final startAfter = commonSeq.startString2;
    if (commonSeq.length == 0) {
      final Iterable<ItemResult<LeftType, RightType?>> result =
          leftItems.map((each) {
        return ItemResult<LeftType, RightType?>(
          each,
          null,
          state: LineDiffState.negative,
        );
      });
      return [
        ...result,
        ...rightItems.map((each) {
          return ItemResult<LeftType?, RightType>(null, each,
              state: LineDiffState.positive);
        }).toList(growable: false)
      ];
    }

    final beforeLeft = leftItems.sublist(0, startBefore);
    final afterLeft = rightItems.sublist(0, startAfter);
    final equal2 =
        leftItems.sublist(startBefore!, startBefore + commonSeq.length!);
    final List<ItemResult<LeftType, RightType>> equal =
        <ItemResult<LeftType, RightType>>[];

    final _sublist =
        rightItems.sublist(startAfter!, startAfter + commonSeq.length!);
    for (var i = 0; i < _sublist.length; ++i) {
      final each = _sublist[i];
      equal.add(ItemResult<LeftType, RightType>(
        equal2[i],
        each,
        state: LineDiffState.neutral,
      ));
    }

    final beforeRight = leftItems.sublist(startBefore + commonSeq.length!);
    final afterRight = rightItems.sublist(startAfter + commonSeq.length!);
    return [
      ...diff(beforeLeft, afterLeft),
      ...equal,
      ...diff(beforeRight, afterRight)
    ];
  }

  static Map<String, List<int>> _indexMap<A>(List<A> list) {
    var map = <String, List<int>>{};
    for (var i = 0; i < list.length; ++i) {
      final each = _typeToString(list[i]);
      map[each] = map[each] ?? [];
      map[each]!.add(i);
    }
    return map;
  }

  /// Helper function to find longest LCS
  static _CommonSubstring _longestCommonSubstring(
      List<Object> seq1, List<Object> seq2) {
    final result =
        _CommonSubstring(startString1: 0, startString2: 0, length: 0);
    final indexMapBefore = _indexMap(seq1);
    var previousOverlap = <int, int>{};

    for (var i = 0; i < seq2.length; ++i) {
      final eachAfter = _typeToString(seq2[i]);
      final indexAfter = i;

      var overlapLength = 0;
      var overlap = <int, int>{};
      var indexesBefore = indexMapBefore[eachAfter] ?? <int>[];
      indexesBefore.forEach((indexBefore) {
        overlapLength =
            (((indexBefore != 0 && (indexBefore - 1) < previousOverlap.length)
                        ? previousOverlap[indexBefore - 1]
                        : 0) ??
                    0) +
                1;
        if (overlapLength > (result.length ?? 0)) {
          result.length = overlapLength;
          result.startString1 = indexBefore - overlapLength + 1;
          result.startString2 = indexAfter - overlapLength + 1;
        }
        overlap[indexBefore] = overlapLength;
      });
      previousOverlap = overlap;
    }

    return result;
  }

  /// Type converting function
  ///
  /// !!! Needs to be edited when handling various different types !!!
  static String _typeToString(dynamic type) {
    if (type is List) {
      return (type).map((e) => _typeToString(e)).join('');
    } else if (type is String) {
      return type;
    } else {
      throw UnsupportedError('FireLineDiff - Unsupported type!');
    }
  }
}

/// Helper class to hold common substring
class _CommonSubstring {
  int? startString1;
  int? startString2;
  int? length;

  _CommonSubstring({this.startString1, this.startString2, this.length});
}
