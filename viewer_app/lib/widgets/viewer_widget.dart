import 'package:flutter/material.dart';
import 'package:viewer_app/model/book.dart';

import 'package:viewer_app/utils.dart';

class ViewerWidget extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  final BookConfig book;

  ViewerWidget({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: book.pages,
        itemBuilder: (_, index) {
          return Row(
            children: [
              Expanded(
                child: loadNetworkImage(book.pageList[index]),
              ),
            ],
          );
        });
  }
}
