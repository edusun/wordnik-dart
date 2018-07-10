import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:wordnik/src/api_token_status.dart';
import 'package:wordnik/src/audio_file.dart';
import 'package:wordnik/src/audio_type.dart';
import 'package:wordnik/src/authentication_token.dart';
import 'package:wordnik/src/bigram.dart';
import 'package:wordnik/src/category.dart';
import 'package:wordnik/src/citation.dart';
import 'package:wordnik/src/content_provider.dart';
import 'package:wordnik/src/definition_search_results.dart';
import 'package:wordnik/src/definition.dart';
import 'package:wordnik/src/example_search_results.dart';
import 'package:wordnik/src/example_usage.dart';
import 'package:wordnik/src/example.dart';
import 'package:wordnik/src/facet_value.dart';
import 'package:wordnik/src/facet.dart';
import 'package:wordnik/src/frequency_summary.dart';
import 'package:wordnik/src/frequency.dart';
import 'package:wordnik/src/label.dart';
import 'package:wordnik/src/note.dart';
import 'package:wordnik/src/part_of_speech.dart';
import 'package:wordnik/src/related.dart';
import 'package:wordnik/src/root.dart';
import 'package:wordnik/src/scored_word.dart';
import 'package:wordnik/src/sentence.dart';
import 'package:wordnik/src/simple_definition.dart';
import 'package:wordnik/src/simple_example.dart';
import 'package:wordnik/src/string_value.dart';
import 'package:wordnik/src/syllable.dart';
import 'package:wordnik/src/text_pron.dart';
import 'package:wordnik/src/user.dart';
import 'package:wordnik/src/word_list_word.dart';
import 'package:wordnik/src/word_list.dart';
import 'package:wordnik/src/word_object.dart';
import 'package:wordnik/src/word_of_the_day.dart';
import 'package:wordnik/src/word_search_result.dart';
import 'package:wordnik/src/word_search_results.dart';

export 'package:wordnik/src/api_token_status.dart';
export 'package:wordnik/src/audio_file.dart';
export 'package:wordnik/src/audio_type.dart';
export 'package:wordnik/src/authentication_token.dart';
export 'package:wordnik/src/bigram.dart';
export 'package:wordnik/src/category.dart';
export 'package:wordnik/src/citation.dart';
export 'package:wordnik/src/content_provider.dart';
export 'package:wordnik/src/definition_search_results.dart';
export 'package:wordnik/src/definition.dart';
export 'package:wordnik/src/example_search_results.dart';
export 'package:wordnik/src/example_usage.dart';
export 'package:wordnik/src/example.dart';
export 'package:wordnik/src/facet_value.dart';
export 'package:wordnik/src/facet.dart';
export 'package:wordnik/src/frequency_summary.dart';
export 'package:wordnik/src/frequency.dart';
export 'package:wordnik/src/label.dart';
export 'package:wordnik/src/note.dart';
export 'package:wordnik/src/part_of_speech.dart';
export 'package:wordnik/src/related.dart';
export 'package:wordnik/src/root.dart';
export 'package:wordnik/src/scored_word.dart';
export 'package:wordnik/src/sentence.dart';
export 'package:wordnik/src/simple_definition.dart';
export 'package:wordnik/src/simple_example.dart';
export 'package:wordnik/src/string_value.dart';
export 'package:wordnik/src/syllable.dart';
export 'package:wordnik/src/text_pron.dart';
export 'package:wordnik/src/user.dart';
export 'package:wordnik/src/word_list_word.dart';
export 'package:wordnik/src/word_list.dart';
export 'package:wordnik/src/word_object.dart';
export 'package:wordnik/src/word_of_the_day.dart';
export 'package:wordnik/src/word_search_result.dart';
export 'package:wordnik/src/word_search_results.dart';

enum ApiMethods {
  get,
  post,
  put,
  delete
}

class Wordnik {
  static const int _apiVersion = 4;
  static const String _apiRoot = 'api.wordnik.com';
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final String apiKey;

  Wordnik(this.apiKey);

  Future<String> _queryApi(String resource, String format, String operation, {String extraTerm, Map<String, String> queryParameters, ApiMethods method = ApiMethods.get, String body, Map<String, String> headers = const {}}) async {
    List<String> segments = ['v$_apiVersion', '$resource.$format', operation];

    if (extraTerm != null) {
      segments.add(extraTerm);
    }

    Uri queryUri = Uri(
      scheme: 'https',
      host: _apiRoot,
      pathSegments: segments,
      queryParameters: queryParameters,
    );

    Map<String, String> fullHeaders = {
      'api_key': apiKey,
      'Content-Type': 'application/json'
    };
    fullHeaders.addAll(headers);

    switch (method) {
      case ApiMethods.post:
        http.Response response = await http.post(queryUri, headers: fullHeaders, body: body);
        return response.body;
      case ApiMethods.put:
        await http.put(queryUri, headers: fullHeaders, body: body);
        return null;
      case ApiMethods.delete:
        await http.delete(queryUri, headers: fullHeaders);
        return null;
      case ApiMethods.get:
      default:
        return await http.read(queryUri, headers: fullHeaders);
    }
  }

  Future<ApiTokenStatus> getApiTokenStatus() async {
    String statusJson = await _queryApi('account', 'json', 'apiTokenStatus');

    return ApiTokenStatus.fromJson(json.decode(statusJson));
  }

  // TODO: GET version of authenticate is not implemented
  Future<AuthenticationToken> authenticate(
    String username,
    String password
  ) async {
    String tokenJson = await _queryApi('account', 'json', 'authenticate', extraTerm: username, method: ApiMethods.post, body: password);

    return AuthenticationToken.fromJson(json.decode(tokenJson));
  }

  Future<User> getLoggedInUser(
    String authToken
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String userJson = await _queryApi('account', 'json', 'user', headers: headers);

    return User.fromJson(json.decode(userJson));
  }

  Future<List<WordList>> getWordListsForLoggedInUser(
    String authToken,
    {
      int skip = 0,
      int limit = 50
    }
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    Map<String, String> parameters = {
      'skip': '$skip',
      'limit': '$limit'
    };

    String wordListJson = await _queryApi('account', 'json', 'wordLists', headers: headers, queryParameters: parameters);

    List<dynamic> wordList = json.decode(wordListJson);

    return wordList.map<WordList>((list) => WordList.fromJson(list)).toList();
  }

  // TODO: Doesn't return any success/failure status?
  Future<Null> deleteWordList(
    String authToken,
    String permalink
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    await _queryApi('wordList', 'json', permalink, headers: headers, method: ApiMethods.delete);
  }

  Future<WordList> getWordListByPermalink(
    String authToken,
    String permalink
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String wordListJson = await _queryApi('wordList', 'json', permalink, headers: headers);

    return WordList.fromJson(json.decode(wordListJson));
  }

  // TODO: doesn't return any success/failure status?
  Future<Null> updateWordList(
    String authToken,
    String permalink,
    WordList modifiedWordList
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String body = json.encode(modifiedWordList);

    await _queryApi('wordList', 'json', permalink, headers: headers, method: ApiMethods.put, body: body);
  }

  // TODO: doesn't return any success/failure status?
  Future<Null> deleteWordsFromWordList(
    String authToken,
    String permalink,
    List<StringValue> wordsToDelete
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String body = json.encode(wordsToDelete);

    await _queryApi('wordList', 'json', permalink, extraTerm: 'deleteWords', headers: headers, method: ApiMethods.post, body: body);
  }

  Future<List<WordListWord>> getWordListWords(
    String authToken,
    String permalink,
    {
      String sortBy = 'createDate',
      String sortOrder = 'desc',
      int skip = 0,
      int limit = 100
    }
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    Map<String, String> parameters = {
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'skip': '$skip',
      'limit': '$limit'
    };

    String wordListWordListJson = await _queryApi('wordList', 'json', permalink, extraTerm: 'words', headers: headers, queryParameters: parameters);

    List<dynamic> wordListWordList = json.decode(wordListWordListJson);

    return wordListWordList.map<WordListWord>((word) => WordListWord.fromJson(word)).toList();
  }

  // TODO: doesn't return any success/failure status?
  Future<Null> addWordsToWordList(
    String authToken,
    String permalink,
    List<StringValue> wordsToAdd
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String body = json.encode(wordsToAdd);

    await _queryApi('wordList', 'json', permalink, extraTerm: 'words', headers: headers, method: ApiMethods.post, body: body);
  }

  Future<WordList> createWordList(
    String authToken,
    WordList newWordList
  ) async {
    Map<String, String> headers = {
      'auth_token': authToken
    };

    String body = json.encode(newWordList);

    String wordListJson = await _queryApi('wordLists', 'json', '', headers: headers, method: ApiMethods.post, body: body);

    return WordList.fromJson(json.decode(wordListJson));
  }

  Future<WordObject> getWord(
    String word,
    {
      bool useCanonical = false,
      bool includeSuggestions = true
    }
  ) async {
    Map<String, String> parameters = {
      'useCanonical': '$useCanonical',
      'includeSuggestions': '$includeSuggestions'
    };

    String wordJson = await _queryApi('word', 'json', word, queryParameters: parameters);

    return WordObject.fromJson(json.decode(wordJson));
  }

  Future<List<Definition>> getDefinitions(
    String word,
    {
      int limit = 200,
      String partOfSpeech,
      bool includeRelated = false,
      List<String> sourceDictionaries,
      bool useCanonical = false,
      bool includeTags = false
    }
  ) async {
    Map<String, String> parameters = {
      'word': word,
      'limit': '$limit',
      'partOfSpeech': partOfSpeech,
      'includeRelated': '$includeRelated',
      'sourceDictionaries': sourceDictionaries?.join(',') ?? '',
      'useCanonical': '$useCanonical',
      'includeTags': '$includeTags'
    };

    String definitionListJson = await _queryApi('word', 'json', word, extraTerm: 'definitions', queryParameters: parameters);
    List<dynamic> definitionList = json.decode(definitionListJson);

    return definitionList.map<Definition>((definition) => Definition.fromJson(definition)).toList();
  }

  Future<WordObject> getRandomWord(
    {
      bool hasDictionaryDef = true,
      String includePartOfSpeech = '',
      String excludePartOfSpeech = '',
      int minCorpusCount = 1,
      int maxCorpusCount = -1,
      int minDictionaryCount = 1,
      int maxDictionaryCount = -1,
      int minLength = 1,
      int maxLength = -1
    }
  ) async {
    Map<String, String> parameters = {
      'hasDictionaryDef': '$hasDictionaryDef',
      'includePartOfSpeech': includePartOfSpeech,
      'excludePartOfSpeech': excludePartOfSpeech,
      'minCorpusCount': '$minCorpusCount',
      'maxCorpusCount': '$maxCorpusCount',
      'minDictionaryCount': '$minDictionaryCount',
      'maxDictionaryCount': '$maxDictionaryCount',
      'minLength': '$minLength',
      'maxLength': '$maxLength'
    };

    String wordJson = await _queryApi('words', 'json', 'randomWord', queryParameters: parameters);

    return WordObject.fromJson(json.decode(wordJson));
  }

  Future<List<WordObject>> getRandomWords(
    {
      bool hasDictionaryDef = true,
      String includePartOfSpeech = '',
      String excludePartOfSpeech = '',
      int minCorpusCount = 1,
      int maxCorpusCount = -1,
      int minDictionaryCount = 1,
      int maxDictionaryCount = -1,
      int minLength = 1,
      int maxLength = -1,
      String sortBy = 'alpha',
      String sortOrder = 'desc',
      int limit = 10
    }
  ) async {
    Map<String, String> parameters = {
      'hasDictionaryDef': '$hasDictionaryDef',
      'includePartOfSpeech': includePartOfSpeech,
      'excludePartOfSpeech': excludePartOfSpeech,
      'minCorpusCount': '$minCorpusCount',
      'maxCorpusCount': '$maxCorpusCount',
      'minDictionaryCount': '$minDictionaryCount',
      'maxDictionaryCount': '$maxDictionaryCount',
      'minLength': '$minLength',
      'maxLength': '$maxLength',
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'limit': '$limit'
    };

    String wordListJson = await _queryApi('words', 'json', 'randomWords', queryParameters: parameters);
    List<dynamic> wordList = json.decode(wordListJson);

    return wordList.map<WordObject>((word) => WordObject.fromJson(word)).toList();
  }

  Future<DefinitionSearchResults> reverseDictionary(
    String query,
    {
      String findSenseForWord,
      String includeSourceDictionaries,
      String excludeSourceDictionaries,
      String includePartOfSpeech,
      String excludePartOfSpeech,
      int minCorpusCount = 5,
      int maxCorpusCount = -1,
      int minLength = 1,
      int maxLength = -1,
      String expandTerms,
      bool includeTags = false,
      String sortBy,
      String sortOrder,
      int skip = 0,
      int limit = 10
    }
  ) async {
    Map<String, String> parameters = {
      'query': query,
      'findSenseForWord': findSenseForWord,
      'includeSourceDictionaries': includeSourceDictionaries,
      'excludeSourceDictionaries': excludeSourceDictionaries,
      'includePartOfSpeech': includePartOfSpeech,
      'excludePartOfSpeech': excludePartOfSpeech,
      'minCorpusCount': '$minCorpusCount',
      'maxCorpusCount': '$maxCorpusCount',
      'minLength': '$minLength',
      'maxLength': '$maxLength',
      'expandTerms': expandTerms,
      'includeTags': '$includeTags',
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'skip': '$skip',
      'limit': '$limit'
    };

    String reverseDictionaryJson = await _queryApi('words', 'json', 'reverseDictionary', queryParameters: parameters);

    return DefinitionSearchResults.fromJson(json.decode(reverseDictionaryJson));
  }

  Future<WordSearchResults> searchWords(
    String query,
    {
      bool allowRegex = false,
      bool caseSensitive = true,
      String includePartOfSpeech,
      String excludePartOfSpeech,
      int minCorpusCount = 5,
      int maxCorpusCount = -1,
      int minDictionaryCount = 1,
      int maxDictionaryCount = -1,
      int minLength = 1,
      int maxLength = -1,
      int skip = 0,
      int limit = 10
    }
  ) async {
    Map<String, String> parameters = {
      'allowRegex': '$allowRegex',
      'caseSensitive': '$caseSensitive',
      'includePartOfSpeech': includePartOfSpeech,
      'excludePartOfSpeech': excludePartOfSpeech,
      'minCorpusCount': '$minCorpusCount',
      'maxCorpusCount': '$maxCorpusCount',
      'minDictionaryCount': '$minDictionaryCount',
      'maxDictionaryCount': '$maxDictionaryCount',
      'minLength': '$minLength',
      'maxLength': '$maxLength',
      'skip': '$skip',
      'limit': '$limit'
    };

    String wordSearchJson = await _queryApi('words', 'json', 'search', extraTerm: query, queryParameters: parameters);

    return WordSearchResults.fromJson(json.decode(wordSearchJson));
  }

  Future<WordOfTheDay> getWordOfTheDay(
    {
      DateTime date
    }
  ) async {
    Map<String, String> parameters = (date == null) ? null : {
      'date': _dateFormat.format(date)
    };

    String wordOfTheDayJson = await _queryApi('words', 'json', 'wordOfTheDay', queryParameters: parameters);

    return WordOfTheDay.fromJson(json.decode(wordOfTheDayJson));
  }
}
