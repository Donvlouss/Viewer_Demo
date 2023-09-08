import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:viewer_app/model/book.dart';
import 'package:viewer_app/model/database.dart';
import 'package:viewer_app/model/search.dart';
import 'package:viewer_app/model/config.dart';

Image loadNetworkImageById(int id, int pageId, {BoxFit fit = BoxFit.fitWidth}) {
  return loadNetworkImage("${HOST}book/$id/$pageId");
}

Image loadNetworkImage(String url, {BoxFit fit = BoxFit.fitWidth}) {
  return Image.network(
    url,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null),
      );
    },
    fit: fit,
  );
}

class NetworkImageResult {
  final bool isVertical;
  final Image widget;

  NetworkImageResult(this.isVertical, this.widget);
}

class NetworkImageProviderResult {
  late ui.Image? image;
  final ImageProvider widget;

  NetworkImageProviderResult(this.widget);
}

Future<NetworkImageResult> loadBufferImage(String url) async {
  var result = await http.Client().get(Uri.parse(url));
  final bytes = result.bodyBytes;
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final uiImage = frame.image;
  return NetworkImageResult(
      uiImage.width < uiImage.height, Image.memory(bytes));
}

Future<NetworkImageProviderResult> loadBufferImageProvider(String url) async {
  final image = Image.network(url);
  var completer = Completer<ui.Image>();
  image.image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((imageInfo, synchronousCall) {
    completer.complete(imageInfo.image);
  }));

  var result = NetworkImageProviderResult(image.image);
  await completer.future.then((future) {
    result.image = future;
  });
  return result;
}

Future<BookConfig?> loadBookConfigById(int id, {bool isShallow = true}) async {
  var url = "${HOST}book/$id/";
  if (isShallow) {
    url = "${url}shallow/";
  }
  return await loadBookConfig(url);
}

Future<BookConfig?> loadBookConfig(String url) async {
  try {
    var result = await http.Client().get(Uri.parse(url));
    var body = utf8.decode(result.body.runes.toList());
    var book = bookConfigFromJson(body);
    for (int i = 0; i < book.pageList.length; ++i) {
      book.pageList[i] = "${HOST}book/${book.id}/$i";
    }
    return book;
  } catch (e) {
    developer.log('Network', error: "Connection Error at Query Book Config");
  }
  return null;
}

Future<List<int>> loadBooks() async {
  try {
    var result = await http.Client().get(Uri.parse("${HOST}books"));
    print("Response: ${result.statusCode}");
    var list = json.decode(result.body) as List<dynamic>;
    print("Json Decode Length: ${list.length}");
    var ret = <int>[];
    for (int i = 0; i < list.length; ++i) {
      ret.add(list[i] as int);
    }
    return ret;
  } catch (e) {
    developer.log('Network', error: "Connection Error at Query Book Book List");
    print("Load Books Error: $e");
  }
  return <int>[];
}

Future<List<int>> queryBooks(List<QueryModel> models) async {
  try {
    var result = await http.Client().post(
      Uri.parse("${HOST}search/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(models),
    );
    var list = json.decode(result.body) as List<dynamic>;
    var ret = <int>[];
    for (int i = 0; i < list.length; ++i) {
      ret.add(list[i] as int);
    }
    return ret;
  } catch (e) {
    developer.log('Network', error: "Connection Error at Query Search");
  }
  return <int>[];
}

Future<Map<String, List<String>>> queryTags() async {
  var ret = <String, List<String>>{};

  for (int i = 0; i < TagConfig.values.length; ++i) {
    var name = TagConfig.values[i].toString().split('.').last;
    ret[name] = <String>[];
    try {
      var result = await http.Client().get(Uri.parse("${HOST}tag/$name"));
      ret[name] = (json.decode(result.body) as List<dynamic>)
          .map((value) => value as String)
          .toList();
    } catch (e) {
      developer.log('Network', error: "Connection Error at Query Tags");
    }
  }

  return ret;
}
