import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:viewer_app/model/book.dart';
import 'package:viewer_app/model/favorite_db.dart';
import 'dart:developer' as developer;

import 'package:viewer_app/model/search.dart';
import 'package:viewer_app/utils.dart';

part 'viewer_event.dart';
part 'viewer_state.dart';

class ViewerBloc extends Bloc<ViewerEvent, ViewerState> {
  late List<int> originalList;
  late List<int> currentList;
  late int index;
  late BookConfig config;
  bool hasBeenSorted = false;
  late Map<String, List<String>> argumentsOfTags;

  Future<void> waitBookGrabDown(int index, {bool isShallow = true}) async {
    developer.log("Length: ${currentList.length}", name: "Bloc.WaitBookDown");
    this.index = index;
    config = (await loadBookConfigById(currentList[this.index],
            isShallow: isShallow)) ??
        createAFailedBook();
  }

  Future<void> doPrevBook() async {
    while (index != 0) {
      await waitBookGrabDown(index - 1, isShallow: false);
      if (config.pageList.isNotEmpty) {
        break;
      }
    }
  }

  Future<void> doNextBook() async {
    while (index != currentList.length - 1) {
      await waitBookGrabDown(index + 1, isShallow: false);
      if (config.pageList.isNotEmpty) {
        break;
      }
    }
  }

  Future<bool> doQueryArgument(QueryType type, List<QueryModel> args) async {
    var results = currentList;
    if (type == QueryType.and) {
      for (var arg in args) {
        var resultList = await queryBooks([arg]);
        if (resultList.isEmpty) {
          return false;
        } else {
          // Has Data, Do Intersection
          results.removeWhere(
            // Remove not intersection
            (element) => !resultList.contains(element),
          );
          // If intersection down is empty, return.
          if (results.isEmpty) {
            return false;
          }
        }
      }
    } else {
      var resultList = await queryBooks(args);
      if (resultList.isEmpty) {
        return false;
      }
      if (type == QueryType.or) {
        // Remove not Intersection
        results.removeWhere(
          (element) => !resultList.contains(element),
        );
      } else if (type == QueryType.not) {
        // Remove Intersection
        results.removeWhere(
          (element) => resultList.contains(element),
        );
      }
    }
    // Final Check
    if (results.isNotEmpty) {
      currentList = results;
      return true;
    }
    return false;
  }

  Future<void> doRandomBook() async {
    do {
      await waitBookGrabDown(Random().nextInt(currentList.length),
          isShallow: false);
    } while (config.pageList.isEmpty);
  }

  ViewerBloc() : super(ViewerInitial()) {
    on<FirstLoadEvent>((event, emit) async {
      developer.log("Length: ${event.list.length}", name: "Bloc.First");
      originalList = event.list.sublist(0).toList();
      currentList = event.list.sublist(0).toList();

      queryTags().then((map) {
        argumentsOfTags = map;
      });

      await waitBookGrabDown(0, isShallow: false);
      emit(ViewerInitial());
      emit(ListChanged(currentList));
      emit(BookChanged(config));
    });
    on<SearchEvent>((event, emit) async {
      var hasData = await doQueryArgument(event.type, event.args);
      if (hasData) {
        await waitBookGrabDown(0);
        emit(ListChanged(currentList));
        emit(BookChanged(config));
        SmartDialog.showToast("Search Down. Has ${currentList.length} Books");
      } else {
        SmartDialog.showToast("Search Down. No Books Found. Abort.");
      }
    });
    on<RestoreEvent>((event, emit) async {
      currentList = originalList.sublist(0).toList();
      await waitBookGrabDown(0);
      SmartDialog.showToast("Reset Down");

      emit(ViewerInitial());
      emit(ListChanged(currentList));
      emit(BookChanged(config));
    });
    on<PreviousBookEvent>((event, emit) async {
      developer.log("Do Previous", name: "Bloc.Prev");

      await doPrevBook();
      emit(BookChanged(config));
    });
    on<NextBookEvent>((event, emit) async {
      developer.log("Do Next", name: "Bloc.Next");

      await doNextBook();
      emit(BookChanged(config));
    });
    on<RandomBookEvent>((event, emit) async {
      await doRandomBook();
      emit(BookChanged(config));
    });
    on<SortBookEvent>((event, emit) async {
      if (!hasBeenSorted || currentList.first > currentList.last) {
        currentList.sort();
        hasBeenSorted = true;
      } else {
        for (int i = 0; i < currentList.length / 2; ++i) {
          var temp = currentList[i];
          currentList[i] = currentList[currentList.length - 1 - i];
          currentList[currentList.length - 1 - i] = temp;
        }
      }
      await waitBookGrabDown(0);
      emit(ListChanged(currentList));
      emit(BookChanged(config));
    });
    on<GoToBookEvent>((event, emit) async {
      developer.log("Go To Book: ${event.index}", name: "Bloc.GoTo");

      if (event.index >= 0 && event.index < currentList.length) {
        await waitBookGrabDown(event.index, isShallow: false);
        if (config.pageList.isEmpty) {
          await doNextBook();
        }
        emit(BookChanged(config));
      }
    });
    on<NewFavoriteEvent>((event, emit) async {
      developer.log(event.name, name: "Bloc.Fav.Add");
      if (FavoriteDB.instance.addFavorite(event.name)) {
        SmartDialog.showToast("Added ${event.name}");
      } else {
        SmartDialog.showToast("[${event.name}] Existed or Some Error");
      }
      emit(FavAdded(FavoriteDB.instance.favoriteMap.keys.toList()));
    });
    on<AddRemoveEvent>((event, emit) async {
      developer.log(
          "Book:${config.id} to ${event.favorite}, isAdd: ${event.isAdd}",
          name: "Bloc.Book.AorR");
      bool r = false;
      if (event.isAdd) {
        r = FavoriteDB.instance.addBookToFav(config.id, event.favorite);
      } else {
        r = FavoriteDB.instance.removeBookFromFav(config.id, event.favorite);
      }
      if (r) {
        SmartDialog.showToast("Added");
      } else {
        SmartDialog.showToast("Removed");
      }
      emit(BookAddRemove(r));
    });
    on<SelectFavoriteEvent>((event, emit) async {
      if (FavoriteDB.instance.favoriteMap.containsKey(event.favorite)) {
        currentList = FavoriteDB.instance.favoriteMap[event.favorite]!.books;
      }
      await waitBookGrabDown(0);
      emit(ListChanged(currentList));
      emit(BookChanged(config));
    });
  }
}
