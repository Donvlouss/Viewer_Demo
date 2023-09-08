// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:viewer_app/model/favorite_db.dart';

import 'package:viewer_app/widgets/viewer_widget.dart';
import 'package:viewer_app/model/book.dart';
import 'package:viewer_app/widgets/custom_slider.dart';
import 'package:viewer_app/bloc/Viewer/viewer_bloc.dart';

@immutable
class PageBookView extends StatefulWidget {
  PageBookView({super.key});

  @override
  State<PageBookView> createState() => _PageBookViewState();
}

class _PageBookViewState extends State<PageBookView> {
  bool hasDialogShow = false;
  TextEditingController addFavoriteTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool hasBookConfig = false;

    return BlocBuilder<ViewerBloc, ViewerState>(builder: (context, state) {
      final bloc = BlocProvider.of<ViewerBloc>(context);
      BookConfig? book;
      ScrollController? scrollController;

      Widget child = Container();
      if (state is BookChanged) {
        book = state.config;
        child = ViewerWidget(book: book);
        scrollController = (child as ViewerWidget).scrollController;
        hasBookConfig = true;
        if (hasDialogShow) {
          SmartDialog.dismiss(status: SmartStatus.allDialog);
          _show(context, bloc, book, scrollController);
        }
      }

      return GestureDetector(
        child: child,
        onTapUp: (detail) {
          if (!hasBookConfig) {
            return;
          }

          var pos = detail.localPosition;
          var box = (context.findRenderObject() as RenderBox).size;
          var w4 = box.width / 4;
          var h4 = box.height / 4;
          if (pos.dx > w4 && pos.dx < w4 * 3) {
            if (pos.dy > h4 && pos.dy < h4 * 3) {
              hasDialogShow = true;
              return _show(context, bloc, book!, scrollController!);
            }
          }
          var value = scrollController!.offset;
          if (pos.dx < w4 * 2) {
            if (value < 50) {
              value = 0;
            } else {
              value -= 50;
            }
          } else {
            if (scrollController.position.maxScrollExtent - value < 50) {
              value = scrollController.position.maxScrollExtent;
            } else {
              value += 50;
            }
          }
          scrollController.animateTo(value,
              duration: const Duration(milliseconds: 50), curve: Curves.ease);
        },
      );
    }, buildWhen: (_, state) {
      return state is BookChanged;
    });
  }

  void _show(BuildContext context, ViewerBloc bloc, BookConfig book,
      ScrollController scrollController) async {
    await _locationDialog(
        context: context,
        bloc: bloc,
        geometry: Alignment.bottomCenter,
        child: CustomSlider(scrollController),
        waitTime: 0,
        book: book);
  }

  Future _locationDialog({
    required BuildContext context,
    required ViewerBloc bloc,
    required AlignmentGeometry geometry,
    required CustomSlider child,
    required int waitTime,
    required BookConfig book,
  }) async {
    SmartDialog.show(
      animationType: SmartAnimationType.fade,
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(children: [
            _topDialog(context, book),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _leftDialog(width: 150, book: book),
                _rightDialog(width: 150, bloc: bloc, book: book)
              ],
            )),
            _bottomDialog(height: 70, bloc: bloc, child: child)
          ]),
        );
      },
    );
    await Future.delayed(Duration(milliseconds: waitTime));
  }

  Widget _topDialog(BuildContext context, BookConfig book) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(book.title),
    );
  }

  Widget _bottomDialog({
    required double height,
    required ViewerBloc bloc,
    required CustomSlider child,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color.fromARGB(150, 9, 10, 10),
      child: Row(children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: IconButton(
            color: Colors.pinkAccent,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              bloc.add(const PreviousBookEvent());
              child.toZero();
            },
          ),
        ),
        Expanded(child: child),
        Container(
          margin: const EdgeInsets.all(10),
          child: IconButton.filled(
            color: Colors.pinkAccent,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () {
              bloc.add(const NextBookEvent());
              child.toZero();
            },
          ),
        ),
      ]),
    );
  }

  Widget _leftDialog({required double width, required BookConfig book}) {
    return SizedBox(
      width: width,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(150, 9, 10, 10),
          child: Column(
            children: [
              ListTile(
                title: const Text("Class:"),
                subtitle: Text(book.bookConfigClass),
              ),
              ListTile(
                title: const Text("Pages:"),
                subtitle: Text("${book.pages}"),
              ),
              if (book.language.isNotEmpty)
                ExpansionTile(
                  title: const Text("Language"),
                  children: List.generate(
                      book.language.length, (i) => Text(book.language[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Parody"),
                  children: List.generate(
                      book.parody.length, (i) => Text(book.parody[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Character"),
                  children: List.generate(
                      book.character.length, (i) => Text(book.character[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Group"),
                  children: List.generate(
                      book.group.length, (i) => Text(book.group[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Artist"),
                  children: List.generate(
                      book.artist.length, (i) => Text(book.artist[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Male"),
                  children: List.generate(
                      book.male.length, (i) => Text(book.male[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Female"),
                  children: List.generate(
                      book.female.length, (i) => Text(book.female[i])),
                ),
              if (book.parody.isNotEmpty)
                ExpansionTile(
                  title: const Text("Other"),
                  children: List.generate(
                      book.other.length, (i) => Text(book.other[i])),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rightDialog(
      {required double width,
      required ViewerBloc bloc,
      required BookConfig book}) {
    return Container(
      color: const Color.fromARGB(150, 9, 10, 10),
      width: width,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.rocket_outlined),
              onPressed: () => bloc.add(const RandomBookEvent()),
              tooltip: "Random Book",
            ),
            const Text(
              "Favorite",
              textAlign: TextAlign.left,
            ),
            ListTile(
              title: const Text("New..."),
              onTap: () async {
                SmartDialog.show(
                  animationType: SmartAnimationType.fade,
                  builder: (_) {
                    return SizedBox(
                      width: 200,
                      height: 100,
                      child: TextField(
                        controller: addFavoriteTextController,
                        keyboardType: TextInputType.text,
                        maxLength: 20,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onEditingComplete: () {
                          var text = addFavoriteTextController.text;
                          // bloc.add(NewFavoriteEvent(text));
                          var r = FavoriteDB.instance.addFavorite(text);
                          if (r) {
                            SmartDialog.showToast("$text Added");
                          } else {
                            SmartDialog.showToast("$text Failed");
                          }

                          addFavoriteTextController.clear();
                          SmartDialog.dismiss(status: SmartStatus.dialog);
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(
              color: Colors.pink,
              thickness: 4,
              indent: 10,
              endIndent: 10,
            ),
            ListenableBuilder(
              listenable: FavoriteDB.instance,
              builder: (context, Widget? child) {
                final favKeys = FavoriteDB.instance.favoriteMap.keys.toList();
                if (favKeys.isEmpty) {
                  return Container();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: favKeys.length,
                  itemBuilder: (context, index) {
                    bool isContain = FavoriteDB
                        .instance.favoriteMap[favKeys[index]]!.books
                        .contains(book.id);
                    return ListTile(
                      title: Text(favKeys[index]),
                      trailing: SizedBox(
                        width: 40,
                        child: isContain
                            ? IconButton(
                                icon: Icon(Icons.favorite,
                                    color: Colors.pink[300]),
                                onPressed: () {
                                  FavoriteDB.instance.removeBookFromFav(
                                      book.id, favKeys[index]);
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.pink[300],
                                ),
                                onPressed: () {
                                  FavoriteDB.instance
                                      .addBookToFav(book.id, favKeys[index]);
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
