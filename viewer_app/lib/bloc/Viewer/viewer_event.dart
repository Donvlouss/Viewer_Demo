part of 'viewer_bloc.dart';

@immutable
abstract class ViewerEvent {
  const ViewerEvent();
}

class FirstLoadEvent extends ViewerEvent {
  final List<int> list;
  const FirstLoadEvent(this.list);
}

class SearchEvent extends ViewerEvent {
  final QueryType type;
  final List<QueryModel> args;
  const SearchEvent(this.args, this.type);
}

class RestoreEvent extends ViewerEvent {
  const RestoreEvent();
}

class PreviousBookEvent extends ViewerEvent {
  const PreviousBookEvent();
}

class NextBookEvent extends ViewerEvent {
  const NextBookEvent();
}

class RandomBookEvent extends ViewerEvent {
  const RandomBookEvent();
}

class SortBookEvent extends ViewerEvent {
  const SortBookEvent();
}

class GoToBookEvent extends ViewerEvent {
  final int index;
  const GoToBookEvent(this.index);
}

class NewFavoriteEvent extends ViewerEvent {
  final String name;
  const NewFavoriteEvent(this.name);
}

class AddRemoveEvent extends ViewerEvent {
  final String favorite;
  final bool isAdd;
  const AddRemoveEvent(this.favorite, this.isAdd);
}

class SelectFavoriteEvent extends ViewerEvent {
  final String favorite;
  const SelectFavoriteEvent(this.favorite);
}
