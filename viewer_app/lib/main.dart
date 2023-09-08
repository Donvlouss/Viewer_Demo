import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:viewer_app/View/page_search.dart';

import 'package:viewer_app/bloc/Viewer/viewer_bloc.dart';
import 'package:viewer_app/View/page_home.dart';
import 'package:viewer_app/model/favorite_db.dart';
import 'package:viewer_app/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bloc = ViewerBloc();
  await FavoriteDB.instance.createDB();

  runApp(MaterialApp(
    home: BlocProvider<ViewerBloc>(
      create: (context) {
        loadBooks().then((value) {
          value.sort();
          bloc.add(FirstLoadEvent(value));
        });
        return bloc;
      },
      child: const PageHome(),
    ),
    navigatorObservers: [FlutterSmartDialog.observer],
    builder: FlutterSmartDialog.init(),
    theme: ThemeData.dark(),
    routes: {
      '/search': (context) => PageSearch(
            bloc: bloc,
          ),
    },
  ));
}
