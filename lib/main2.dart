import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _textEditingController = TextEditingController();
  late SharedPreferences _prefs;
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _items = _prefs.getStringList('items') ?? [];
    });
  }

  Future<void> _addItem(String item) async {
    setState(() {
      _items.add(item);
    });
    await _prefs.setStringList('items', _items);
  }

  Future<void> _updateItem(int index, String newItem) async {
    setState(() {
      _items[index] = newItem;
    });
    await _prefs.setStringList('items', _items);
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await _prefs.setStringList('items', _items);
  }

  Future<void> _clearData() async {
    setState(() {
      _items.clear();
    });
    await _prefs.remove('items');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Storage Demo'),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Enter a new item',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _addItem(_textEditingController.text);
                  _textEditingController.clear();
                },
                child: Text('Add'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {

                    return Dismissible(
                      key: ValueKey(_items[index]),
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          await _deleteItem(index);
                        } else if (direction == DismissDirection.startToEnd) {
                          // Show dialog to edit item
                          String? newItem = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {

                              return AlertDialog(
                                title: Text('Edit Item'),
                                content: TextField(
                                  controller: TextEditingController(text: _items[index]),
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await _updateItem(index, _textEditingController.text);
                                      Navigator.of(context).pop(_textEditingController.text);
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.edit),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete),
                      ),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(_items[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _clearData();
                },
                child: Text('Clear All'),
              ),
            ],
          ),
        )
    );
  }
}
