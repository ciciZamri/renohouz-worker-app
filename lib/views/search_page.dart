import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/models/job.dart';
import 'package:renohouz_worker/providers/search_history_provider.dart';

class SearchPage extends StatefulWidget {
  final String initialText;
  const SearchPage({
    Key? key,
    this.initialText = '',
  }) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController controller;
  List<String> suggestions = [];

  void updateSuggestion(String prefix, SearchHistoryProvider searchHistory) {
    if (prefix.isEmpty) {
      setState(() {
        suggestions = searchHistory.list?.map((e) => e).toList() ?? [];
      });
    } else {
      Job.queryAutoComplete(prefix).then((results) {
        setState(() {
          suggestions = results;
        });
      }).catchError((err) {
      });
    }
  }

  Widget autoCompleteText(String word, SearchHistoryProvider searchHistory) {
    return ListTile(
      title: Text(word),
      leading: searchHistory.list?.contains(word) ?? false ? const Icon(Icons.history) : const Icon(Icons.search),
      visualDensity: VisualDensity.compact,
      onTap: () {
        controller.text = word;
        searchHistory.add(word);
        Navigator.pop(context, word);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchHistoryProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Colors.lightGreen[700]),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.lightGreen[700],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search for workers',
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        onChanged: (val) => updateSuggestion(val, provider),
                        autofocus: true,
                        controller: controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (val) {
                          provider.add(val);
                          Navigator.pop(context, val);
                        },
                      ),
                    ),
                  ],
                ),
                Container(width: double.infinity, height: 1, color: Colors.grey),
                Expanded(
                  child: provider.list == null
                      ? SizedBox()
                      : ListView(
                          children: [...suggestions.map((e) => autoCompleteText(e, provider))],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
