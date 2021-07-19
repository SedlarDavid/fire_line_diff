import 'package:fire_line_diff/fire_line_diff.dart';
import 'package:test/test.dart';

class _A {
  final double _i;

  _A(this._i);

  toString() {
    return this._i.toString();
  }
}

void main() {
  group("Main", () {
    test("Base test", () {
      final left = [new _A(1), new _A(2), new _A(4)];

      final right = [new _A(1), new _A(3), new _A(4)];

      final result = FireLineDiff.diff(left, right);

      expect(result.length, equals(4));

      expect(result[0].state, equals(LineDiffState.neutral));
      expect(result[0].left, equals(left[0]));
      expect(result[0].right, equals(right[0]));

      expect(result[1].state, equals(LineDiffState.negative));
      expect(result[1].left, equals(left[1]));

      expect(result[2].state, equals(LineDiffState.positive));
      expect(result[2].right, equals(right[1]));

      expect(result[3].state, equals(LineDiffState.neutral));
      expect(result[3].left, equals(left[2]));
      expect(result[3].right, equals(right[2]));
    });

    test('LCS test', () {
      var a = [
        'class GitException implements Exception {}',
        '',
        'class GitNotFound implements GitException {}',
      ];

      var b = [
        'class GitNotFound implements GitException {}',
        '',
        'class InvalidRepoException implements GitException {'
      ];

      // Should not throw exception anymore
      final result = FireLineDiff.diff(a, b);

      expect(result.length, equals(5));
    });
  });
}
