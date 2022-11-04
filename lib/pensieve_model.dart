import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PensieveModel extends ChangeNotifier {
  Map<String, String>? _contents;
  bool get hasData => _contents != null && _contents!.isNotEmpty;
  FlutterSecureStorage storage;

  PensieveModel({required this.storage});

  void initStorage() {
    storage.readAll().then((value) {
      _contents = value;
      notifyListeners();
    });
  }

  Iterable<Thought>? get thoughts {
    return _contents?.values.map((e) => Thought.fromJson(jsonDecode(e)));
  }

  Future<void> addNote({required String content}) {
    final key = '${DateTime.now()}';
    _contents?[key] = content;
    notifyListeners();
    return storage.write(key: key, value: content);
  }

  Future<void> addThought(Thought thought) {
    final key = '${DateTime.now()}';
    final content = jsonEncode(thought);
    _contents?[key] = content;
    notifyListeners();
    return storage.write(key: key, value: content);
  }
}

class Thought {
  final String who;
  final String what;
  final DateTime when;

  Thought({required this.who, required this.what, required this.when});
  Thought.fromJson(Map<String, dynamic> json)
      : who = json['who'],
        what = json['what'],
        when = DateTime.parse(json['when']);

  Map<String, dynamic> toJson() {
    return {
      'who': who,
      'what': what,
      'when': '$when',
    };
  }
}
