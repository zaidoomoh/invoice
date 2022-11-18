// ignore_for_file: non_constant_identifier_settingss

class ItemsModel {
  String? unit_id;
  String? unit;
  
  ItemsModel({
    this.unit_id,
    this.unit,
    
  });

  // Create a Recipe from JSON data
factory ItemsModel.fromJson(Map<String, dynamic> json) => ItemsModel(
 unit_id: json['unit_id'],
 unit: json['unit'],
 
);
// Convert our Recipe to JSON to make it easier when you store
// it in the database
Map<String, dynamic> toJson() => {
 'unit_id': unit_id,
 'unit': unit
 
};


  // ItemsModel.fromJson(Map<String, dynamic> json) {
  //   unit_id = json['unit_id'];
  //   unit = json['unit'];
    
  // }
  // Map<String, dynamic> toMap() {
  //   return {
  //     'unit_id': unit_id,
  //     "unit": unit,
      
  //   };
  // }
}

class Clients {
  final int id;
  final String settings;
  final int settings_state;

  const Clients({
    required this.id,
    required this.settings,
    required this.settings_state,
  });

  factory Clients.fromJson(Map<String, dynamic> json) => Clients(
 id: json['id'],
 settings: json['settings'],
 settings_state: json['settings_state'],
);
// Convert our Recipe to JSON to make it easier when you store
// it in the database
Map<String, dynamic> toJson() => {
 'id': id,
 'settings': settings,
 'settings_state': settings_state
 
};
}
