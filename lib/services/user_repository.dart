import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class RegisteredUser {
  final String name;
  final String email;

  const RegisteredUser(this.name, this.email);
}

class EmailTakenException implements Exception {
  const EmailTakenException();
}

class UserRepository {
  UserRepository({this._factory, this._path});

  final DatabaseFactory? _factory;
  final String? _path;
  Database? _db;

  static const _iterations = 10000;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;
    final factory = _factory ?? databaseFactory;
    final path = _path ?? p.join(await getDatabasesPath(), 'moodcart.db');
    return _db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        '''),
      ),
    );
  }

  Future<RegisteredUser> register(
    String name,
    String email,
    String password,
  ) async {
    final db = await _database;
    final salt = _newSalt();
    try {
      await db.insert('users', {
        'name': name,
        'email': email,
        'password_hash': _hash(password, salt),
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw const EmailTakenException();
      rethrow;
    }
    return RegisteredUser(name, email);
  }

  Future<RegisteredUser?> authenticate(String email, String password) async {
    final db = await _database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final ok = _sameHash(
      _hash(password, row['salt']! as String),
      row['password_hash']! as String,
    );
    return ok
        ? RegisteredUser(row['name']! as String, row['email']! as String)
        : null;
  }

  Future<void> close() async => _db?.close();

  static String _newSalt() {
    final random = Random.secure();
    return base64Encode(List.generate(16, (_) => random.nextInt(256)));
  }

  static String _hash(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var block = hmac.convert([...base64Decode(salt), 0, 0, 0, 1]).bytes;
    final result = List<int>.of(block);
    for (var i = 1; i < _iterations; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return base64Encode(result);
  }

  static bool _sameHash(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
