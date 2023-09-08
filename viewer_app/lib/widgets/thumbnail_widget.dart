import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viewer_app/View/page_book_view.dart';

import 'package:viewer_app/bloc/Viewer/viewer_bloc.dart';
import 'package:viewer_app/utils.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({super.key});

  bool checkStateValid(ViewerState state) {
    return state is ListChanged;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ViewerBloc>(context);
    return BlocBuilder<ViewerBloc, ViewerState>(
      builder: (context, state) {
        if (!checkStateValid(state)) {
          return Container();
        }
        var list = (state as ListChanged).indexList;
        var w = (context.findRenderObject() as RenderBox).size.width;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
                future: loadBookConfigById(list[index], isShallow: false),
                builder: (context, snapshot) {
                  Widget image = Container();
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    if (snapshot.data!.pageList.isNotEmpty) {
                      image = loadNetworkImageById(list[index], 0,
                          fit: BoxFit.fitHeight);
                    }
                  }
                  return SizedBox(
                    width: w,
                    height: 100,
                    child: ListTile(
                      leading: SizedBox(width: 100, height: 100, child: image),
                      title: Text(snapshot.data?.title ?? "Loading..."),
                      subtitle: Text(
                          '${snapshot.data?.bookConfigClass ?? "Loading..."} - ${snapshot.data?.pages ?? 0} Pages'),
                      isThreeLine: true,
                      onTap: () {
                        if (bloc.isClosed) {
                          return;
                        }
                        bloc.add(GoToBookEvent(index));
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          if (snapshot.data!.pageList.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute<Widget>(
                              builder: (context) {
                                return BlocProvider<ViewerBloc>.value(
                                  value: bloc,
                                  child: PageBookView(),
                                );
                              },
                            ));
                          }
                        }
                      },
                    ),
                  );
                });
          },
        );
      },
      buildWhen: (_, state) {
        return checkStateValid(state);
      },
    );
  }
}
