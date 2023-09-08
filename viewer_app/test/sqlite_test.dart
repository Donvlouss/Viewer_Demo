import 'package:test/test.dart';

import 'package:viewer_app/model/favorite_db.dart';

void main() {
  FavoriteDB.instance.createDB();

  test("Add Fav", () {
    expect(true, FavoriteDB.instance.addFavorite("Test1"));
    expect(true, FavoriteDB.instance.favoriteMap.containsKey("Test1"));
  });

  test("Add Book", () {
    expect(true, FavoriteDB.instance.addBookToFav(1, "Test1"));
    expect(true, FavoriteDB.instance.addBookToFav(2, "Test1"));
    expect(true, FavoriteDB.instance.addBookToFav(3, "Test1"));
  });

  test("Remove Book", () {
    expect(true, FavoriteDB.instance.removeBookFromFav(1, "Test1"));
  });

  test("Rename Fav", () {
    expect(true, FavoriteDB.instance.renameFavoriteSlot("Test2", "Test1"));
  });

  test("Remove Fav", () {
    expect(true, FavoriteDB.instance.removeFav("Test2"));
  });
}
