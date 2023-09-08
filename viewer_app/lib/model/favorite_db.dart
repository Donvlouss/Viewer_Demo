import 'dart:io';

import 'package:flutter/material.dart' as widget;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:developer' as developer;

class Result {
  final bool ok;
  final dynamic data;

  Result(this.ok, this.data);
}

class Favorite {
  final int uid;
  String _name;
  List<int> books = <int>[];

  Favorite(this.uid, String name) : _name = name;

  String get name => _name;
  set name(String newName) {
    _name = name;
  }

  void add(int idx) {
    if (!books.contains(idx)) {
      books.add(idx);
    }
  }

  void remove(int idx) {
    if (books.contains(idx)) {
      books.remove(idx);
    }
  }
}

class FavoriteDB extends widget.ChangeNotifier {
  static String _dbName = "Favorite.db";

  // Singleton
  static FavoriteDB? _instance;
  factory FavoriteDB() => instance;
  static FavoriteDB get instance => _instance ??= FavoriteDB._();
  FavoriteDB._();

  static final Map<String, Favorite> _favoriteMap = <String, Favorite>{};
  Map<String, Favorite> get favoriteMap => _favoriteMap;

  Result autoOpenClose(Function(Database) F) {
    try {
      final db = sqlite3.open(FavoriteDB._dbName);
      var res = F(db);
      db.dispose();
      return Result(true, res);
    } catch (e) {
      developer.log("Exception: $e", name: "Favorite.Log");
    }
    return Result(false, null);
  }

  Future<void> createDB() async {
    if (Platform.isAndroid) {
      var path = await getApplicationDocumentsDirectory();
      _dbName = "${path.path}/$_dbName";
    }

    autoOpenClose((Database db) {
      db.execute('''
      CREATE TABLE IF NOT EXISTS FavSlots(
        Idx INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT
        )
      ''');
      db.execute('''
      CREATE TABLE IF NOT EXISTS BookSlots(
          Idx INTEGER PRIMARY KEY AUTOINCREMENT,
          BookIdx INTEGER,
          SlotIdx INTEGER
      )
      ''');
    });
    developer.log("Created", name: "DB.Create");
    queryAll();
  }

  // Search
  List<Favorite> queryFavorites() {
    Result r = autoOpenClose(
      (Database db) {
        var ret = <Favorite>[];
        final ResultSet resultSet = db.select("SELECT * FROM FavSlots");
        developer.log("SELECT * FROM FavSlots", name: "DB.Query.Favorite");
        for (final Row row in resultSet) {
          ret.add(Favorite(row['Idx'], row['Name'].toString()));
        }
        return ret;
      },
    );
    return r.ok ? r.data : <Favorite>[];
  }

  Favorite queryFavoriteSlot(Favorite arg) {
    Result _ = autoOpenClose(
      (Database db) {
        final resultSet = db.select(
            "SELECT BookIdx FROM BookSlots WHERE SlotIdx=?;",
            [arg.uid.toString()]);
        developer.log("SELECT BookIdx FROM BookSlots WHERE SlotIdx=${arg.uid};",
            name: "DB.Query.Slot");
        for (final row in resultSet) {
          arg.books.add(row["BookIdx"]);
        }
      },
    );
    return arg;
  }

  void queryAll() {
    var slots = queryFavorites();
    for (final slot in slots) {
      _favoriteMap[slot.name] = queryFavoriteSlot(slot);
    }
  }

  // Add Remove
  bool addFavorite(String name) {
    if (_favoriteMap.containsKey(name)) {
      return false;
    }

    Result r = autoOpenClose(
      (Database db) {
        db.execute('''
          INSERT INTO FavSlots (Name) VALUES (?);
        ''', [name]);
        developer.log("INSERT INTO FavSlots (Name) VALUES (\"$name\");",
            name: "DB.Add.Fav");
      },
    );
    if (!r.ok) {
      return false;
    }

    for (final fav in queryFavorites()) {
      if (!_favoriteMap.containsKey(fav.name)) {
        _favoriteMap[name] = fav;
      }
    }
    if (r.ok) {
      notifyListeners();
    }
    return r.ok;
  }

  bool addBookToFav(int bookIdx, String fav) {
    if (!_favoriteMap.containsKey(fav)) {
      return false;
    }

    Result r = autoOpenClose(
      (Database db) {
        db.execute('''
          INSERT INTO BookSlots (BookIdx, SlotIdx) VALUES (?, ?);
        ''', [bookIdx.toString(), _favoriteMap[fav]!.uid.toString()]);
        developer.log(
            "INSERT INTO BookSlots (BookIdx, SlotIdx) VALUES ($bookIdx, ${_favoriteMap[fav]!.uid});",
            name: "DB.Add.Book");
      },
    );
    if (!r.ok) {
      return false;
    }
    _favoriteMap[fav]!.add(bookIdx);
    notifyListeners();
    return r.ok;
  }

  bool renameFavoriteSlot(String name, String fav) {
    if (!_favoriteMap.containsKey(fav)) {
      return false;
    }

    Result r = autoOpenClose(
      (Database db) {
        developer.log(
            "UPDATE FavSlots SET Name=\"$name\" WHERE Idx= ${_favoriteMap[fav]!.uid};",
            name: "DB.Rename");
        db.execute('''
          UPDATE FavSlots SET Name=? WHERE Idx=?;
        ''', [name, _favoriteMap[fav]!.uid]);
      },
    );
    if (r.ok) {
      _favoriteMap[name] = _favoriteMap[fav]!;
      _favoriteMap.remove(fav);
      notifyListeners();
    }
    return r.ok;
  }

  bool removeBookFromFav(int bookIdx, String fav) {
    if (!_favoriteMap.containsKey(fav)) {
      return false;
    }

    Result r = autoOpenClose(
      (Database db) {
        db.execute('''
          DELETE FROM BookSlots WHERE BookIdx=? AND SlotIdx=?;
        ''', [bookIdx.toString(), _favoriteMap[fav]!.uid.toString()]);
        developer.log(
            "DELETE FROM BookSlots WHERE BookIdx=$bookIdx AND SlotIdx=${_favoriteMap[fav]!.uid};",
            name: "DB.Remove");
      },
    );
    if (!r.ok) {
      return false;
    }
    _favoriteMap[fav]!.remove(bookIdx);
    notifyListeners();
    return r.ok;
  }

  bool removeFav(String fav) {
    if (!_favoriteMap.containsKey(fav)) {
      return false;
    }

    Result r = autoOpenClose((Database db) {
      db.execute('''
          DELETE FROM FavSlots WHERE Idx=?;
        ''', [_favoriteMap[fav]!.uid]);
      db.execute('''
          DELETE FROM BookSlots WHERE SlotIdx=?
        ''', [_favoriteMap[fav]!.uid]);
    });
    if (r.ok) {
      _favoriteMap.remove(fav);
      notifyListeners();
    }
    return r.ok;
  }
}
