import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_app/Baseball_Pieces/Player.dart';

class DatabaseHelper{


  static final _dbName = 'DrixPitchers.db';
  static final _dbVersion = 1;
  static final _tableName = 'DrixData';

  static final _columnPitcher = 'Pitcher';
  static final _columnGames = 'Games';
  static final _columnPitches = 'Pitches';


  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();

    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);


  }

  Future _onCreate(Database db, int version) async{
    await db.execute(
      ''' 
      CREATE TABLE $_tableName( 
      $_columnPitcher STRING PRIMARY KEY
      $_columnGames GAMEINSTANCE NOT NULL
      $_columnPitches LIST<PITCH> NOT NULL )
      '''
    );
  }
  

  // Future<List<Player>> getPitchers() async {
  //   Database db = await instance.database;
  //   var pitchers = await db.query(_tableName, orderBy: _columnPitcher);
  //   List<Player> pitcherList = pitchers.isNotEmpty
  //     ? pitchers.map((c) => Player.fromMap(c)).toList()
  //       : [];
    
  //   return pitcherList;

  // }

  // Future<int> add(Player pitcher) async {
  //   Database db = await instance.database;
  //   return await db.insert(pitcher.name, pitcher.toMap());
  // }

}


