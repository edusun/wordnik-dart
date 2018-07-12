import 'package:test/test.dart';
import 'package:wordnik/wordnik.dart';

import 'credentials.dart';

void main() {
  Credentials credentials;
  setUp(() async {
    credentials = Credentials.fromFile('credentials.json');
  });

  test('checks initialization of wordnik api', () {
    final Wordnik wordnik = Wordnik(credentials.apiKey);
    expect(wordnik.apiKey, credentials.apiKey);
  });
}
