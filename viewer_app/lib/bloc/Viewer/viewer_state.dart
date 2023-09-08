part of 'viewer_bloc.dart';

@immutable
abstract class ViewerState extends Equatable {
  const ViewerState();
}

class ViewerInitial extends ViewerState {
  ViewerInitial() {
    developer.log("Initialized", name: "BlocState");
  }

  @override
  List<Object?> get props => [];
}

class BookChanged extends ViewerState {
  final BookConfig config;

  BookChanged(this.config) {
    developer.log("BookChanged: ${config.id}", name: "BlocState");
  }

  @override
  List<Object?> get props => [config];
}

class ListChanged extends ViewerState {
  final List<int> indexList;

  ListChanged(this.indexList) {
    developer.log("ListChanged: ${indexList.length}", name: "BlocState");
  }

  @override
  List<Object?> get props => [indexList];
}

class FavAdded extends ViewerState {
  final List<String> favorites;

  const FavAdded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class BookAddRemove extends ViewerState {
  final bool isSuccess;

  const BookAddRemove(this.isSuccess);

  @override
  List<Object?> get props => [isSuccess];
}
