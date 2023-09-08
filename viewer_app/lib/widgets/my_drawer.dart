import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:viewer_app/bloc/Viewer/viewer_bloc.dart';
import 'package:viewer_app/model/favorite_db.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ViewerBloc>(context);
    final renameController = TextEditingController();
    var favKeys = FavoriteDB.instance.favoriteMap.keys.toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink[300],
            ),
            child: const Text("Menu"),
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      bloc.add(const RestoreEvent());
                    },
                    tooltip: "Reset",
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      bloc.add(const SortBookEvent());
                    },
                    tooltip: "Sort",
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/search');
                    },
                    tooltip: "Search",
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.pink[100],
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          const Padding(padding: EdgeInsets.all(8), child: Text("Favorites")),
          if (favKeys.isEmpty)
            Container()
          else
            ListenableBuilder(
              listenable: FavoriteDB.instance,
              builder: (context, Widget? child) {
                favKeys = FavoriteDB.instance.favoriteMap.keys.toList();
                return ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: favKeys.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 50,
                      child: ListTile(
                        key: UniqueKey(),
                        leading: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.favorite,
                              color: Colors.pinkAccent,
                            )),
                        title: Text(favKeys[index]),
                        subtitle: Text(
                            "${FavoriteDB.instance.favoriteMap[favKeys[index]]!.books.length} Books"),
                        onTap: () async {
                          SmartDialog.show(
                            builder: (_) {
                              return CupertinoAlertDialog(
                                title: const Text("Select"),
                                content:
                                    Text("Select ${favKeys[index]} Favorite?"),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("No"),
                                  ),
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      bloc.add(
                                          SelectFavoriteEvent(favKeys[index]));
                                      SmartDialog.dismiss(
                                          status: SmartStatus.dialog);
                                    },
                                    child: const Text("Yes"),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                SmartDialog.show(
                                  animationType: SmartAnimationType.fade,
                                  builder: (_) {
                                    return SizedBox(
                                      width: 200,
                                      height: 100,
                                      child: TextField(
                                        controller: renameController,
                                        keyboardType: TextInputType.text,
                                        maxLength: 20,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        onEditingComplete: () {
                                          var text = renameController.text;
                                          renameController.clear();
                                          var _ = FavoriteDB.instance
                                              .renameFavoriteSlot(
                                                  text, favKeys[index]);
                                          SmartDialog.dismiss(
                                              status: SmartStatus.dialog);
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                SmartDialog.show(
                                  builder: (_) {
                                    return CupertinoAlertDialog(
                                      title: const Text("Remove"),
                                      content: const Text(
                                          "Process with remove action?"),
                                      actions: [
                                        CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("No"),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () {
                                            if (FavoriteDB.instance
                                                .removeFav(favKeys[index])) {
                                              SmartDialog.showToast("Removed");
                                            } else {
                                              SmartDialog.showToast("Failed");
                                            }
                                            SmartDialog.dismiss(
                                                status: SmartStatus.dialog);
                                          },
                                          child: const Text("Yes"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
