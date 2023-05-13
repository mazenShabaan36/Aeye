import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:avatar_glow/avatar_glow.dart';

/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechListScreen(),
    );
  }
}
*/

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;
  final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  DatabaseHelper._instance();

  String tableName = 'speech';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Stream<List<Map<String, dynamic>>> get stream => controller.stream;

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'speech.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)');
    print('Database created');
  }

  Future<int> insert(String text) async {
    final db = await instance.db;
    final id = await db.insert(tableName, {'text': text});
    _notifyListeners();
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await instance.db;
    print(db);
    return await db.query(tableName);
  }

  Future<int> delete(int id) async {
    final db = await instance.db;
    final done = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
    return done;
  }

  void _notifyListeners() async {
    final data = await queryAll();
    controller.sink.add(data);
  }

  Stream<List<Map<String, dynamic>>> get dataStream => controller.stream;
  void dispose() {
    controller.close();
  }
}

final stt.SpeechToText _speech = stt.SpeechToText();

Future<void> startListening() async {
  bool isAvailable = await _speech.initialize();
  if (isAvailable) {
    _speech.listen(
      onResult: (result) async {
        String text = result.recognizedWords;
        await DatabaseHelper.instance.insert(text);
      },
    );
  }
}

class SpeechListScreen extends StatefulWidget {
  @override
  _SpeechListScreenState createState() => _SpeechListScreenState();
}

class _SpeechListScreenState extends State<SpeechListScreen> {
  List<Map<String, dynamic>> _speechList = [];

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;
  List<String> dates = ["10-10-2022 14:23"];

  @override
  void initState() {
    super.initState();
    _querySpeeches();
    DatabaseHelper.instance.stream.listen((data) {
      setState(() {
        _speechList = data;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    DatabaseHelper.instance.dispose();
    super.dispose();
  }

  void _querySpeeches() async {
    final speechList = await DatabaseHelper.instance.queryAll();
    print(speechList);
    setState(() {
      _speechList = speechList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1c4257),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff1c4257), // Colors.lightBlue.shade100,
        elevation: 0,
        title: Text(
          'Notes',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 21,
              letterSpacing: 1.2),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40)),
            // color: Colors.cyan,
            gradient: LinearGradient(colors: [
              Colors.blueGrey[800],
              Colors.lightBlue.shade300,
              //Colors.blueGrey[600],
              // Color(0xff1c4257),
              // Color(0xff253340),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: DatabaseHelper.instance.dataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data;
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView.builder(
                  itemCount: items.length, //_speechList.length,
                  itemBuilder: (context, index) {
                    //final speech = _speechList[index];
                    final speech = items[index];
                    DateTime addedTime = DateTime.now();
                    print(speech);
                    return GestureDetector(
                      onDoubleTap: () {
                        DatabaseHelper.instance.delete(speech['id']);
                        dates.removeAt(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  speech['text'],
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blueGrey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03,
                                    ),
                                    Text(
                                      dates[index],
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        /* ListTile(
                          title: Text(
                            speech['text'],
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),*/
                      ),
                    );
                  },
                ),
              ),
            );
          }),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);

      if (_text != '') {
        DateTime addedTime = DateTime.now();
        String add =
            "${addedTime.day}-${addedTime.month}-${addedTime.year}  ${addedTime.hour}:${addedTime.minute}";
        DatabaseHelper.instance.insert(_text);
        dates.add(add);
      }
      _speech.stop();
      _text = '';
    }
    print(_text);
    // DatabaseHelper.instance.insert(_text);
    print(_speechList);
  }
}
