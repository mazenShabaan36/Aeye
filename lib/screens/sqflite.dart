import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDB {
  static Database _db;
  Future<Database> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

//create database
  initialDb() async {
    String dataBasePath = await getDatabasesPath(); //get path of database
    String path = join(dataBasePath, 'mazen.db');
    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 3, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
   CREATE TABLE "notes" (
    "id" INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "note" TEXT NOT NULL
   )
 ''');
  }

  //select data
  readData(String sql) async {
    Database mydb = await db;
    List<Map> response = await mydb.rawQuery(sql);
    return response;
  }

  //insert data
  insertData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawInsert(sql);
    return response;
  }

  //update Data
  updateData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawUpdate(sql);
    return response;
  }

  // Delete data
  deleteData(String sql) async {
    Database mydb = await db;
    int response = await mydb.rawDelete(sql);
    return response;
  }
}

class used {
  //use async and awiatt
  int response =
      SqlDB().insertData("INSERT INTO  'notes' (note) VALUES ('note on') ");
  List<Map> response2 = SqlDB().readData("SELECT * FROM 'notes'");
  int response3 = SqlDB().deleteData("DELETE FROM 'notes' WHERE id = 8");
  int response4 = SqlDB()
      .updateData("UPDATE  'notes' SET  'note' = 'note six' WHERE id = 6");
}
