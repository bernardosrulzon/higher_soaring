import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  static Database database;

  AppDatabase._();

  setupDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = "$databasesPath/higher_soaring.db";

    await deleteDatabase(path);

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE positions ('
              'id INTEGER PRIMARY KEY,'
              'created_at TEXT,'
              'latitude REAL,'
              'longitude REAL,'
              'altitude REAL,'
              'speed REAL'
              ')');
        });
    print('Finished setup');
  }

  insertPositionData(String createdAt, double latitude, double longitude, double altitude, double speed) async {
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO positions(created_at, latitude, longitude, altitude, speed) '
              'VALUES("$createdAt", $latitude, $longitude, $altitude, $speed)');
    });
  }

  Future<List> queryData(query) async {
    List<Map> list = await database.rawQuery(query);
    return list;
  }
}