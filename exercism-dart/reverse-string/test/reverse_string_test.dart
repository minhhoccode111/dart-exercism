import 'package:reverse_string/reverse_string.dart';
import 'package:test/test.dart';

void main() {
  group('ReverseString', () {
    test('an empty string', () {
      final result = reverse('');
      expect(result, equals(''));
    }, skip: false);

    test('a word', () {
      final result = reverse('robot');
      expect(result, equals('tobor'));
    }, skip: false);

    test('a capitalized word', () {
      final result = reverse('Ramen');
      expect(result, equals('nemaR'));
    }, skip: false);

    test('a sentence with punctuation', () {
      final result = reverse('I\'m hungry!');
      expect(result, equals('!yrgnuh m\'I'));
    }, skip: false);

    test('a palindrome', () {
      final result = reverse('racecar');
      expect(result, equals('racecar'));
    }, skip: false);

    test('an even-sized word', () {
      final result = reverse('drawer');
      expect(result, equals('reward'));
    }, skip: false);

    test('wide characters', () {
      final result = reverse('子猫');
      expect(result, equals('猫子'));
    }, skip: false);
  });
}
