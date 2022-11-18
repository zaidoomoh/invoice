import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test1/items_modle.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  // 1
  static const _databaseName = 'invoice.db';
  static const _databaseVersion = 1;
// 2
  static const unitsTable = 'units';
  static const settingsTable = 'settings';
  static const recipeId = 'recipeId';
  static const ingredientId = 'ingredientId';
// 3
  static late BriteDatabase _streamDatabase;
// make this a singleton class
// 4
  
// 5
  static var lock = Lock();
// only have a single app-wide reference to the database
// 6
  static Database? _database;

// SQL code to create the database table
// 1
  Future _onCreate(Database db, int version) async {
    // 2
    await db.execute('''
 CREATE TABLE units(unit_id INTEGER PRIMARY KEY AUTOINCREMENT,unit VARCHAR NOT NULL)
''');
    // 3
    await db.execute('''
 CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT,settings VARCHAR NOT NULL,settings_state VARCHAR NOT NULL)
 ''');
  }

// this opens the database (and creates it if it doesn't exist)
// 1
  Future<Database> _initDatabase() async {
    // 2
    final documentsDirectory = await getApplicationDocumentsDirectory();
    // 3
    final path = join(
      documentsDirectory.path,
      _databaseName,
    );
    // 4

    Sqflite.setDebugModeOn(true);
    // 5
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // 1
Future<Database> get database async {
 // 2
 if (_database != null) return _database!;
 // Use this object to prevent concurrent access to data
 // 3
 await lock.synchronized(() async {
 // lazily instantiate the db the first time it is accessed
 // 4
 if (_database == null) {
 // 5
 _database = await _initDatabase();
 // 6
 _streamDatabase = BriteDatabase(_database!);
 }
 });
 return _database!;
}

// 1
Future<BriteDatabase> get streamDatabase async {
 // 2
 await database;
 return _streamDatabase;
}

List<ItemsModel> parseRecipes(List<Map<String, dynamic>> recipeList) 
{
 final recipes = <ItemsModel>[];
 // 1
 for (final recipeMap in recipeList) {
 // 2
 final recipe = ItemsModel.fromJson(recipeMap);
 // 3
 recipes.add(recipe);
 }
 // 4
 return recipes;
}
List<Clients> parseIngredients(List<Map<String, dynamic>> 
ingredientList) {
 final ingredients = <Clients>[];
 for (final ingredientMap in ingredientList) {
 // 5
 final ingredient = Clients.fromJson(ingredientMap);
 ingredients.add(ingredient);
 }
 return ingredients;
}

Future<List<ItemsModel>> findAllRecipes() async {
 // 1
 final db = await instance.streamDatabase;
 // 2
 final recipeList = await db.query(unitsTable);
 // 3
 final recipes = parseRecipes(recipeList);
 return recipes;
}

Stream<List<ItemsModel>> watchAllRecipes() async* {
 final db = await instance.streamDatabase;
 // 1
 yield* db
 // 2
 .createQuery(unitsTable)
 // 3
 .mapToList((row) => ItemsModel.fromJson(row));
}

Stream<List<Clients>> watchAllIngredients() async* {
 final db = await instance.streamDatabase;
 yield* db
 .createQuery(settingsTable)
 .mapToList((row) => Clients.fromJson(row));
}




}

class SqliteRepository  {
 // 3
 final dbHelper = DatabaseHelper.instance;

 Future<List<ItemsModel>> findAllRecipes() {
 return dbHelper.findAllRecipes();
}

Stream<List<ItemsModel>> watchAllRecipes() {
 return dbHelper.watchAllRecipes();
}
@override
Stream<List<Clients>> watchAllIngredients() {
 return dbHelper.watchAllIngredients();
}

Future init() async {
 // 1
 await dbHelper.database;
 return Future.value();
}






}
