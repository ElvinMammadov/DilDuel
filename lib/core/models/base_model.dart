import 'package:equatable/equatable.dart';

/// Base class for all models in the application
abstract class BaseModel extends Equatable {
  /// Converts the model to a map
  Map<String, dynamic> toMap();

  /// Creates a copy of the model with some fields replaced
  BaseModel copyWith();

  @override
  bool get stringify => true;
}

/// Mixin for database models
mixin DatabaseModel {
  /// The database id of the model
  int? get id;

  /// The table name for this model
  String get tableName;

  /// The primary key column name
  String get primaryKey => 'id';
}
