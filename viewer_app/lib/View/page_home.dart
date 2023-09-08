import 'package:flutter/material.dart';
import 'package:viewer_app/widgets/thumbnail_widget.dart';
import 'package:viewer_app/widgets/my_drawer.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const MyDrawer(),
        body: NestedScrollView(
          body: const ThumbnailWidget(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                title: Text("Viewer"),
                snap: true,
                floating: true,
              ),
            ];
          },
        ));
  }
}
