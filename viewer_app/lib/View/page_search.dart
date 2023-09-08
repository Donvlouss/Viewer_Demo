import 'package:flutter/material.dart';
import 'package:viewer_app/bloc/Viewer/viewer_bloc.dart';
import 'package:viewer_app/model/database.dart';
import 'package:viewer_app/model/search.dart';

class PageSearch extends StatefulWidget {
  final ViewerBloc bloc;
  const PageSearch({super.key, required this.bloc});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  List<QueryModel> arguments = <QueryModel>[];
  final List<String> tags = TagConfig.values.map((e) => e.name).toList();
  List<String> selectedTags = <String>[];
  List<String> selectedArguments = <String>[];
  QueryType? queryType = QueryType.and;

  void prepareQuery() {
    if (selectedTags.isEmpty) {
      return;
    }

    for (int i = 0; i < selectedTags.length; ++i) {
      var tag = toEnum(selectedTags[i]);
      if (tag != null) {
        arguments.add(QueryModel(tag, selectedArguments[i]));
      }
    }
    widget.bloc.add(SearchEvent(arguments, queryType!));
  }

  Card buildCard(int index) {
    return Card(
      key: UniqueKey(),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            selectedTags.removeAt(index);
            selectedArguments.removeAt(index);
            setState(
              () {},
            );
          },
        ),
        Expanded(
          child: Column(children: [
            const Text("Tag"),
            DropdownButton(
              value: selectedTags[index],
              items: tags.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTags[index] = value!;
                });
              },
            )
          ]),
        ),
        Expanded(
          child: Column(
            children: [
              const Text("Argument"),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(
                      text: index < selectedArguments.length
                          ? selectedArguments[index]
                          : "Please Input ... "),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    selectedArguments[index] = textEditingValue.text;
                    return widget.bloc.argumentsOfTags[selectedTags[index]]!
                        .where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: ((option) {
                    selectedArguments[index] = option;
                  }),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(
                () {
                  selectedTags.add(tags.first);
                  selectedArguments.add('');
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              prepareQuery();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.remove_circle),
        onPressed: () {
          setState(
            () {
              arguments.clear();
              selectedTags.clear();
            },
          );
        },
      ),
      body: Column(
        children: [
          Row(
              children: QueryType.values.map(
            (e) {
              return Expanded(
                child: SizedBox(
                  height: 50,
                  child: RadioListTile(
                    title: Text(e.toString().split('.').last.toUpperCase()),
                    value: e,
                    groupValue: queryType,
                    onChanged: (value) {
                      queryType = value;
                    },
                  ),
                ),
              );
            },
          ).toList()),
          Expanded(
            child: ListView.builder(
              itemCount: selectedTags.length,
              itemBuilder: (context, index) {
                return buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
