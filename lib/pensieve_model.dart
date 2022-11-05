import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class PensieveModel extends ChangeNotifier {
  Map<String, String>? _contents;
  bool get hasData => _contents != null && _contents!.isNotEmpty;
  FlutterSecureStorage storage;
  static const _idGenerator = Uuid();

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

  Future<void> addThought(Thought thought) {
    assert(thought.uuid == null);
    final key = _idGenerator.v1();
    final content = jsonEncode(thought.withUuid(key));
    _contents?[key] = content;
    notifyListeners();
    return storage.write(key: key, value: content);
  }

  Future<void> deleteOne(String uuid) {
    _contents!.remove(uuid);
    notifyListeners();
    return storage.delete(key: uuid);
  }
}

class Thought {
  final String who;
  final String what;
  final DateTime when;
  final String? uuid;

  Thought({
    required this.who,
    required this.what,
    required this.when,
    this.uuid,
  });

  Thought withUuid(String uuid) {
    return Thought(who: who, what: what, when: when, uuid: uuid);
  }

  Thought.fromJson(Map<String, dynamic> json)
      : who = json['who'],
        what = json['what'],
        when = DateTime.parse(json['when']),
        uuid = json['uuid'];

  Map<String, dynamic> toJson() {
    return {
      'who': who,
      'what': what,
      'when': '$when',
      'uuid': uuid,
    };
  }
}
