import 'package:hive/hive.dart';
part 'hive_model.g.dart';

@HiveType(typeId:0)
class AddClients extends HiveObject{
  @HiveField(0)
  late String name;
  @HiveField(1)
  late int num;
  
}
class Boxes{
  static Box<AddClients> get()=>Hive.box<AddClients>("clients");
}