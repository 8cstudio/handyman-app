// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedCategoriesTable extends CachedCategories
    with TableInfo<$CachedCategoriesTable, CachedCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, imageUrl, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CachedCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CachedCategoriesTable createAlias(String alias) {
    return $CachedCategoriesTable(attachedDatabase, alias);
  }
}

class CachedCategory extends DataClass implements Insertable<CachedCategory> {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  const CachedCategory(
      {required this.id,
      required this.name,
      this.description,
      this.imageUrl,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CachedCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      sortOrder: Value(sortOrder),
    );
  }

  factory CachedCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CachedCategory copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          int? sortOrder}) =>
      CachedCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CachedCategory copyWithCompanion(CachedCategoriesCompanion data) {
    return CachedCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, imageUrl, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.sortOrder == this.sortOrder);
}

class CachedCategoriesCompanion extends UpdateCompanion<CachedCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CachedCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCategoriesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CachedCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? imageUrl,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CachedCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedServicesTable extends CachedServices
    with TableInfo<$CachedServicesTable, CachedService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        price,
        durationMinutes,
        imageUrl,
        categoryId,
        categoryName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_services';
  @override
  VerificationContext validateIntegrity(Insertable<CachedService> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedService(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name']),
    );
  }

  @override
  $CachedServicesTable createAlias(String alias) {
    return $CachedServicesTable(attachedDatabase, alias);
  }
}

class CachedService extends DataClass implements Insertable<CachedService> {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;
  const CachedService(
      {required this.id,
      required this.name,
      this.description,
      required this.price,
      required this.durationMinutes,
      this.imageUrl,
      required this.categoryId,
      this.categoryName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    return map;
  }

  CachedServicesCompanion toCompanion(bool nullToAbsent) {
    return CachedServicesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      durationMinutes: Value(durationMinutes),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      categoryId: Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
    );
  }

  factory CachedService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedService(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
    };
  }

  CachedService copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? price,
          int? durationMinutes,
          Value<String?> imageUrl = const Value.absent(),
          String? categoryId,
          Value<String?> categoryName = const Value.absent()}) =>
      CachedService(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        price: price ?? this.price,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        categoryName:
            categoryName.present ? categoryName.value : this.categoryName,
      );
  CachedService copyWithCompanion(CachedServicesCompanion data) {
    return CachedService(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      price: data.price.present ? data.price.value : this.price,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedService(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, price, durationMinutes,
      imageUrl, categoryId, categoryName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedService &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.durationMinutes == this.durationMinutes &&
          other.imageUrl == this.imageUrl &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName);
}

class CachedServicesCompanion extends UpdateCompanion<CachedService> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<int> durationMinutes;
  final Value<String?> imageUrl;
  final Value<String> categoryId;
  final Value<String?> categoryName;
  final Value<int> rowid;
  const CachedServicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedServicesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required double price,
    required int durationMinutes,
    this.imageUrl = const Value.absent(),
    required String categoryId,
    this.categoryName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        price = Value(price),
        durationMinutes = Value(durationMinutes),
        categoryId = Value(categoryId);
  static Insertable<CachedService> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<int>? durationMinutes,
    Expression<String>? imageUrl,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (imageUrl != null) 'image_url': imageUrl,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedServicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? price,
      Value<int>? durationMinutes,
      Value<String?>? imageUrl,
      Value<String>? categoryId,
      Value<String?>? categoryName,
      Value<int>? rowid}) {
    return CachedServicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedServicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBookingsTable extends CachedBookings
    with TableInfo<$CachedBookingsTable, CachedBooking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceNameMeta =
      const VerificationMeta('serviceName');
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
      'service_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _servicePriceMeta =
      const VerificationMeta('servicePrice');
  @override
  late final GeneratedColumn<double> servicePrice = GeneratedColumn<double>(
      'service_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerNameMeta =
      const VerificationMeta('providerName');
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
      'provider_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceName,
        servicePrice,
        address,
        notes,
        scheduledAt,
        status,
        providerName,
        customerName,
        chatRoomId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_bookings';
  @override
  VerificationContext validateIntegrity(Insertable<CachedBooking> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
          _serviceNameMeta,
          serviceName.isAcceptableOrUnknown(
              data['service_name']!, _serviceNameMeta));
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('service_price')) {
      context.handle(
          _servicePriceMeta,
          servicePrice.isAcceptableOrUnknown(
              data['service_price']!, _servicePriceMeta));
    } else if (isInserting) {
      context.missing(_servicePriceMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
          _providerNameMeta,
          providerName.isAcceptableOrUnknown(
              data['provider_name']!, _providerNameMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBooking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBooking(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_name'])!,
      servicePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}service_price'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      providerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_name']),
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id']),
    );
  }

  @override
  $CachedBookingsTable createAlias(String alias) {
    return $CachedBookingsTable(attachedDatabase, alias);
  }
}

class CachedBooking extends DataClass implements Insertable<CachedBooking> {
  final String id;
  final String serviceName;
  final double servicePrice;
  final String address;
  final String? notes;
  final DateTime scheduledAt;
  final String status;
  final String? providerName;
  final String? customerName;
  final String? chatRoomId;
  const CachedBooking(
      {required this.id,
      required this.serviceName,
      required this.servicePrice,
      required this.address,
      this.notes,
      required this.scheduledAt,
      required this.status,
      this.providerName,
      this.customerName,
      this.chatRoomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_name'] = Variable<String>(serviceName);
    map['service_price'] = Variable<double>(servicePrice);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || providerName != null) {
      map['provider_name'] = Variable<String>(providerName);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || chatRoomId != null) {
      map['chat_room_id'] = Variable<String>(chatRoomId);
    }
    return map;
  }

  CachedBookingsCompanion toCompanion(bool nullToAbsent) {
    return CachedBookingsCompanion(
      id: Value(id),
      serviceName: Value(serviceName),
      servicePrice: Value(servicePrice),
      address: Value(address),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      providerName: providerName == null && nullToAbsent
          ? const Value.absent()
          : Value(providerName),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      chatRoomId: chatRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(chatRoomId),
    );
  }

  factory CachedBooking.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBooking(
      id: serializer.fromJson<String>(json['id']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      servicePrice: serializer.fromJson<double>(json['servicePrice']),
      address: serializer.fromJson<String>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      providerName: serializer.fromJson<String?>(json['providerName']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      chatRoomId: serializer.fromJson<String?>(json['chatRoomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceName': serializer.toJson<String>(serviceName),
      'servicePrice': serializer.toJson<double>(servicePrice),
      'address': serializer.toJson<String>(address),
      'notes': serializer.toJson<String?>(notes),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'providerName': serializer.toJson<String?>(providerName),
      'customerName': serializer.toJson<String?>(customerName),
      'chatRoomId': serializer.toJson<String?>(chatRoomId),
    };
  }

  CachedBooking copyWith(
          {String? id,
          String? serviceName,
          double? servicePrice,
          String? address,
          Value<String?> notes = const Value.absent(),
          DateTime? scheduledAt,
          String? status,
          Value<String?> providerName = const Value.absent(),
          Value<String?> customerName = const Value.absent(),
          Value<String?> chatRoomId = const Value.absent()}) =>
      CachedBooking(
        id: id ?? this.id,
        serviceName: serviceName ?? this.serviceName,
        servicePrice: servicePrice ?? this.servicePrice,
        address: address ?? this.address,
        notes: notes.present ? notes.value : this.notes,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        providerName:
            providerName.present ? providerName.value : this.providerName,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        chatRoomId: chatRoomId.present ? chatRoomId.value : this.chatRoomId,
      );
  CachedBooking copyWithCompanion(CachedBookingsCompanion data) {
    return CachedBooking(
      id: data.id.present ? data.id.value : this.id,
      serviceName:
          data.serviceName.present ? data.serviceName.value : this.serviceName,
      servicePrice: data.servicePrice.present
          ? data.servicePrice.value
          : this.servicePrice,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBooking(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicePrice: $servicePrice, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('providerName: $providerName, ')
          ..write('customerName: $customerName, ')
          ..write('chatRoomId: $chatRoomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serviceName, servicePrice, address, notes,
      scheduledAt, status, providerName, customerName, chatRoomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBooking &&
          other.id == this.id &&
          other.serviceName == this.serviceName &&
          other.servicePrice == this.servicePrice &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.providerName == this.providerName &&
          other.customerName == this.customerName &&
          other.chatRoomId == this.chatRoomId);
}

class CachedBookingsCompanion extends UpdateCompanion<CachedBooking> {
  final Value<String> id;
  final Value<String> serviceName;
  final Value<double> servicePrice;
  final Value<String> address;
  final Value<String?> notes;
  final Value<DateTime> scheduledAt;
  final Value<String> status;
  final Value<String?> providerName;
  final Value<String?> customerName;
  final Value<String?> chatRoomId;
  final Value<int> rowid;
  const CachedBookingsCompanion({
    this.id = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.servicePrice = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.providerName = const Value.absent(),
    this.customerName = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBookingsCompanion.insert({
    required String id,
    required String serviceName,
    required double servicePrice,
    required String address,
    this.notes = const Value.absent(),
    required DateTime scheduledAt,
    required String status,
    this.providerName = const Value.absent(),
    this.customerName = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serviceName = Value(serviceName),
        servicePrice = Value(servicePrice),
        address = Value(address),
        scheduledAt = Value(scheduledAt),
        status = Value(status);
  static Insertable<CachedBooking> custom({
    Expression<String>? id,
    Expression<String>? serviceName,
    Expression<double>? servicePrice,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<DateTime>? scheduledAt,
    Expression<String>? status,
    Expression<String>? providerName,
    Expression<String>? customerName,
    Expression<String>? chatRoomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceName != null) 'service_name': serviceName,
      if (servicePrice != null) 'service_price': servicePrice,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (providerName != null) 'provider_name': providerName,
      if (customerName != null) 'customer_name': customerName,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBookingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? serviceName,
      Value<double>? servicePrice,
      Value<String>? address,
      Value<String?>? notes,
      Value<DateTime>? scheduledAt,
      Value<String>? status,
      Value<String?>? providerName,
      Value<String?>? customerName,
      Value<String?>? chatRoomId,
      Value<int>? rowid}) {
    return CachedBookingsCompanion(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      providerName: providerName ?? this.providerName,
      customerName: customerName ?? this.customerName,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (servicePrice.present) {
      map['service_price'] = Variable<double>(servicePrice.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookingsCompanion(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicePrice: $servicePrice, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('providerName: $providerName, ')
          ..write('customerName: $customerName, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMessagesTable extends CachedMessages
    with TableInfo<$CachedMessagesTable, CachedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chatRoomId,
        content,
        senderId,
        senderName,
        messageType,
        createdAt,
        readAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_messages';
  @override
  VerificationContext validateIntegrity(Insertable<CachedMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $CachedMessagesTable createAlias(String alias) {
    return $CachedMessagesTable(attachedDatabase, alias);
  }
}

class CachedMessage extends DataClass implements Insertable<CachedMessage> {
  final String id;
  final String chatRoomId;
  final String content;
  final String senderId;
  final String senderName;
  final String messageType;
  final DateTime createdAt;
  final DateTime? readAt;
  const CachedMessage(
      {required this.id,
      required this.chatRoomId,
      required this.content,
      required this.senderId,
      required this.senderName,
      required this.messageType,
      required this.createdAt,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    map['content'] = Variable<String>(content);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['message_type'] = Variable<String>(messageType);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  CachedMessagesCompanion toCompanion(bool nullToAbsent) {
    return CachedMessagesCompanion(
      id: Value(id),
      chatRoomId: Value(chatRoomId),
      content: Value(content),
      senderId: Value(senderId),
      senderName: Value(senderName),
      messageType: Value(messageType),
      createdAt: Value(createdAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory CachedMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMessage(
      id: serializer.fromJson<String>(json['id']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      content: serializer.fromJson<String>(json['content']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      messageType: serializer.fromJson<String>(json['messageType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
      'content': serializer.toJson<String>(content),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'messageType': serializer.toJson<String>(messageType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  CachedMessage copyWith(
          {String? id,
          String? chatRoomId,
          String? content,
          String? senderId,
          String? senderName,
          String? messageType,
          DateTime? createdAt,
          Value<DateTime?> readAt = const Value.absent()}) =>
      CachedMessage(
        id: id ?? this.id,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        content: content ?? this.content,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        messageType: messageType ?? this.messageType,
        createdAt: createdAt ?? this.createdAt,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  CachedMessage copyWithCompanion(CachedMessagesCompanion data) {
    return CachedMessage(
      id: data.id.present ? data.id.value : this.id,
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
      content: data.content.present ? data.content.value : this.content,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName:
          data.senderName.present ? data.senderName.value : this.senderName,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessage(')
          ..write('id: $id, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('content: $content, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('messageType: $messageType, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chatRoomId, content, senderId, senderName,
      messageType, createdAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMessage &&
          other.id == this.id &&
          other.chatRoomId == this.chatRoomId &&
          other.content == this.content &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.messageType == this.messageType &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt);
}

class CachedMessagesCompanion extends UpdateCompanion<CachedMessage> {
  final Value<String> id;
  final Value<String> chatRoomId;
  final Value<String> content;
  final Value<String> senderId;
  final Value<String> senderName;
  final Value<String> messageType;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const CachedMessagesCompanion({
    this.id = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.content = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.messageType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMessagesCompanion.insert({
    required String id,
    required String chatRoomId,
    required String content,
    required String senderId,
    required String senderName,
    this.messageType = const Value.absent(),
    required DateTime createdAt,
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chatRoomId = Value(chatRoomId),
        content = Value(content),
        senderId = Value(senderId),
        senderName = Value(senderName),
        createdAt = Value(createdAt);
  static Insertable<CachedMessage> custom({
    Expression<String>? id,
    Expression<String>? chatRoomId,
    Expression<String>? content,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<String>? messageType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (content != null) 'content': content,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (messageType != null) 'message_type': messageType,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chatRoomId,
      Value<String>? content,
      Value<String>? senderId,
      Value<String>? senderName,
      Value<String>? messageType,
      Value<DateTime>? createdAt,
      Value<DateTime?>? readAt,
      Value<int>? rowid}) {
    return CachedMessagesCompanion(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('content: $content, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('messageType: $messageType, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageRoomMetaTable extends MessageRoomMeta
    with TableInfo<$MessageRoomMetaTable, MessageRoomMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageRoomMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasMoreOlderMeta =
      const VerificationMeta('hasMoreOlder');
  @override
  late final GeneratedColumn<bool> hasMoreOlder = GeneratedColumn<bool>(
      'has_more_older', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_more_older" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [chatRoomId, hasMoreOlder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_room_meta';
  @override
  VerificationContext validateIntegrity(
      Insertable<MessageRoomMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    if (data.containsKey('has_more_older')) {
      context.handle(
          _hasMoreOlderMeta,
          hasMoreOlder.isAcceptableOrUnknown(
              data['has_more_older']!, _hasMoreOlderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatRoomId};
  @override
  MessageRoomMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRoomMetaData(
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id'])!,
      hasMoreOlder: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_more_older'])!,
    );
  }

  @override
  $MessageRoomMetaTable createAlias(String alias) {
    return $MessageRoomMetaTable(attachedDatabase, alias);
  }
}

class MessageRoomMetaData extends DataClass
    implements Insertable<MessageRoomMetaData> {
  final String chatRoomId;
  final bool hasMoreOlder;
  const MessageRoomMetaData(
      {required this.chatRoomId, required this.hasMoreOlder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_room_id'] = Variable<String>(chatRoomId);
    map['has_more_older'] = Variable<bool>(hasMoreOlder);
    return map;
  }

  MessageRoomMetaCompanion toCompanion(bool nullToAbsent) {
    return MessageRoomMetaCompanion(
      chatRoomId: Value(chatRoomId),
      hasMoreOlder: Value(hasMoreOlder),
    );
  }

  factory MessageRoomMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRoomMetaData(
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      hasMoreOlder: serializer.fromJson<bool>(json['hasMoreOlder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatRoomId': serializer.toJson<String>(chatRoomId),
      'hasMoreOlder': serializer.toJson<bool>(hasMoreOlder),
    };
  }

  MessageRoomMetaData copyWith({String? chatRoomId, bool? hasMoreOlder}) =>
      MessageRoomMetaData(
        chatRoomId: chatRoomId ?? this.chatRoomId,
        hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      );
  MessageRoomMetaData copyWithCompanion(MessageRoomMetaCompanion data) {
    return MessageRoomMetaData(
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
      hasMoreOlder: data.hasMoreOlder.present
          ? data.hasMoreOlder.value
          : this.hasMoreOlder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRoomMetaData(')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('hasMoreOlder: $hasMoreOlder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatRoomId, hasMoreOlder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRoomMetaData &&
          other.chatRoomId == this.chatRoomId &&
          other.hasMoreOlder == this.hasMoreOlder);
}

class MessageRoomMetaCompanion extends UpdateCompanion<MessageRoomMetaData> {
  final Value<String> chatRoomId;
  final Value<bool> hasMoreOlder;
  final Value<int> rowid;
  const MessageRoomMetaCompanion({
    this.chatRoomId = const Value.absent(),
    this.hasMoreOlder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageRoomMetaCompanion.insert({
    required String chatRoomId,
    this.hasMoreOlder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatRoomId = Value(chatRoomId);
  static Insertable<MessageRoomMetaData> custom({
    Expression<String>? chatRoomId,
    Expression<bool>? hasMoreOlder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (hasMoreOlder != null) 'has_more_older': hasMoreOlder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageRoomMetaCompanion copyWith(
      {Value<String>? chatRoomId,
      Value<bool>? hasMoreOlder,
      Value<int>? rowid}) {
    return MessageRoomMetaCompanion(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (hasMoreOlder.present) {
      map['has_more_older'] = Variable<bool>(hasMoreOlder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageRoomMetaCompanion(')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('hasMoreOlder: $hasMoreOlder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatRoomMappingsTable extends ChatRoomMappings
    with TableInfo<$ChatRoomMappingsTable, ChatRoomMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookingIdMeta =
      const VerificationMeta('bookingId');
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
      'booking_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [bookingId, chatRoomId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_room_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRoomMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('booking_id')) {
      context.handle(_bookingIdMeta,
          bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta));
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookingId};
  @override
  ChatRoomMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomMapping(
      bookingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}booking_id'])!,
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id'])!,
    );
  }

  @override
  $ChatRoomMappingsTable createAlias(String alias) {
    return $ChatRoomMappingsTable(attachedDatabase, alias);
  }
}

class ChatRoomMapping extends DataClass implements Insertable<ChatRoomMapping> {
  final String bookingId;
  final String chatRoomId;
  const ChatRoomMapping({required this.bookingId, required this.chatRoomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['booking_id'] = Variable<String>(bookingId);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    return map;
  }

  ChatRoomMappingsCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomMappingsCompanion(
      bookingId: Value(bookingId),
      chatRoomId: Value(chatRoomId),
    );
  }

  factory ChatRoomMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomMapping(
      bookingId: serializer.fromJson<String>(json['bookingId']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookingId': serializer.toJson<String>(bookingId),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
    };
  }

  ChatRoomMapping copyWith({String? bookingId, String? chatRoomId}) =>
      ChatRoomMapping(
        bookingId: bookingId ?? this.bookingId,
        chatRoomId: chatRoomId ?? this.chatRoomId,
      );
  ChatRoomMapping copyWithCompanion(ChatRoomMappingsCompanion data) {
    return ChatRoomMapping(
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomMapping(')
          ..write('bookingId: $bookingId, ')
          ..write('chatRoomId: $chatRoomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookingId, chatRoomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomMapping &&
          other.bookingId == this.bookingId &&
          other.chatRoomId == this.chatRoomId);
}

class ChatRoomMappingsCompanion extends UpdateCompanion<ChatRoomMapping> {
  final Value<String> bookingId;
  final Value<String> chatRoomId;
  final Value<int> rowid;
  const ChatRoomMappingsCompanion({
    this.bookingId = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatRoomMappingsCompanion.insert({
    required String bookingId,
    required String chatRoomId,
    this.rowid = const Value.absent(),
  })  : bookingId = Value(bookingId),
        chatRoomId = Value(chatRoomId);
  static Insertable<ChatRoomMapping> custom({
    Expression<String>? bookingId,
    Expression<String>? chatRoomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookingId != null) 'booking_id': bookingId,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatRoomMappingsCompanion copyWith(
      {Value<String>? bookingId,
      Value<String>? chatRoomId,
      Value<int>? rowid}) {
    return ChatRoomMappingsCompanion(
      bookingId: bookingId ?? this.bookingId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomMappingsCompanion(')
          ..write('bookingId: $bookingId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatInboxRowsTable extends ChatInboxRows
    with TableInfo<$ChatInboxRowsTable, ChatInboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatInboxRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookingIdMeta =
      const VerificationMeta('bookingId');
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
      'booking_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceNameMeta =
      const VerificationMeta('serviceName');
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
      'service_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        bookingId,
        chatRoomId,
        serviceName,
        lastMessage,
        lastMessageAt,
        unreadCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_inbox_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ChatInboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('booking_id')) {
      context.handle(_bookingIdMeta,
          bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta));
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
          _serviceNameMeta,
          serviceName.isAcceptableOrUnknown(
              data['service_name']!, _serviceNameMeta));
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookingId};
  @override
  ChatInboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatInboxRow(
      bookingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}booking_id'])!,
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id'])!,
      serviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_name'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message']),
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
    );
  }

  @override
  $ChatInboxRowsTable createAlias(String alias) {
    return $ChatInboxRowsTable(attachedDatabase, alias);
  }
}

class ChatInboxRow extends DataClass implements Insertable<ChatInboxRow> {
  final String bookingId;
  final String chatRoomId;
  final String serviceName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  const ChatInboxRow(
      {required this.bookingId,
      required this.chatRoomId,
      required this.serviceName,
      this.lastMessage,
      this.lastMessageAt,
      required this.unreadCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['booking_id'] = Variable<String>(bookingId);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    map['service_name'] = Variable<String>(serviceName);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    return map;
  }

  ChatInboxRowsCompanion toCompanion(bool nullToAbsent) {
    return ChatInboxRowsCompanion(
      bookingId: Value(bookingId),
      chatRoomId: Value(chatRoomId),
      serviceName: Value(serviceName),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
    );
  }

  factory ChatInboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatInboxRow(
      bookingId: serializer.fromJson<String>(json['bookingId']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookingId': serializer.toJson<String>(bookingId),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
      'serviceName': serializer.toJson<String>(serviceName),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
    };
  }

  ChatInboxRow copyWith(
          {String? bookingId,
          String? chatRoomId,
          String? serviceName,
          Value<String?> lastMessage = const Value.absent(),
          Value<DateTime?> lastMessageAt = const Value.absent(),
          int? unreadCount}) =>
      ChatInboxRow(
        bookingId: bookingId ?? this.bookingId,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        serviceName: serviceName ?? this.serviceName,
        lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );
  ChatInboxRow copyWithCompanion(ChatInboxRowsCompanion data) {
    return ChatInboxRow(
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
      serviceName:
          data.serviceName.present ? data.serviceName.value : this.serviceName,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatInboxRow(')
          ..write('bookingId: $bookingId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('serviceName: $serviceName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookingId, chatRoomId, serviceName,
      lastMessage, lastMessageAt, unreadCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatInboxRow &&
          other.bookingId == this.bookingId &&
          other.chatRoomId == this.chatRoomId &&
          other.serviceName == this.serviceName &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount);
}

class ChatInboxRowsCompanion extends UpdateCompanion<ChatInboxRow> {
  final Value<String> bookingId;
  final Value<String> chatRoomId;
  final Value<String> serviceName;
  final Value<String?> lastMessage;
  final Value<DateTime?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<int> rowid;
  const ChatInboxRowsCompanion({
    this.bookingId = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatInboxRowsCompanion.insert({
    required String bookingId,
    required String chatRoomId,
    required String serviceName,
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : bookingId = Value(bookingId),
        chatRoomId = Value(chatRoomId),
        serviceName = Value(serviceName);
  static Insertable<ChatInboxRow> custom({
    Expression<String>? bookingId,
    Expression<String>? chatRoomId,
    Expression<String>? serviceName,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookingId != null) 'booking_id': bookingId,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (serviceName != null) 'service_name': serviceName,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatInboxRowsCompanion copyWith(
      {Value<String>? bookingId,
      Value<String>? chatRoomId,
      Value<String>? serviceName,
      Value<String?>? lastMessage,
      Value<DateTime?>? lastMessageAt,
      Value<int>? unreadCount,
      Value<int>? rowid}) {
    return ChatInboxRowsCompanion(
      bookingId: bookingId ?? this.bookingId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      serviceName: serviceName ?? this.serviceName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatInboxRowsCompanion(')
          ..write('bookingId: $bookingId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('serviceName: $serviceName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedCategoriesTable cachedCategories =
      $CachedCategoriesTable(this);
  late final $CachedServicesTable cachedServices = $CachedServicesTable(this);
  late final $CachedBookingsTable cachedBookings = $CachedBookingsTable(this);
  late final $CachedMessagesTable cachedMessages = $CachedMessagesTable(this);
  late final $MessageRoomMetaTable messageRoomMeta =
      $MessageRoomMetaTable(this);
  late final $ChatRoomMappingsTable chatRoomMappings =
      $ChatRoomMappingsTable(this);
  late final $ChatInboxRowsTable chatInboxRows = $ChatInboxRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedCategories,
        cachedServices,
        cachedBookings,
        cachedMessages,
        messageRoomMeta,
        chatRoomMappings,
        chatInboxRows
      ];
}

typedef $$CachedCategoriesTableCreateCompanionBuilder
    = CachedCategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CachedCategoriesTableUpdateCompanionBuilder
    = CachedCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CachedCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CachedCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CachedCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CachedCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()> {
  $$CachedCategoriesTableTableManager(
      _$AppDatabase db, $CachedCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion(
            id: id,
            name: name,
            description: description,
            imageUrl: imageUrl,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion.insert(
            id: id,
            name: name,
            description: description,
            imageUrl: imageUrl,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()>;
typedef $$CachedServicesTableCreateCompanionBuilder = CachedServicesCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required double price,
  required int durationMinutes,
  Value<String?> imageUrl,
  required String categoryId,
  Value<String?> categoryName,
  Value<int> rowid,
});
typedef $$CachedServicesTableUpdateCompanionBuilder = CachedServicesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<double> price,
  Value<int> durationMinutes,
  Value<String?> imageUrl,
  Value<String> categoryId,
  Value<String?> categoryName,
  Value<int> rowid,
});

class $$CachedServicesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedServicesTable> {
  $$CachedServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => ColumnFilters(column));
}

class $$CachedServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedServicesTable> {
  $$CachedServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedServicesTable> {
  $$CachedServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => column);
}

class $$CachedServicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedServicesTable,
    CachedService,
    $$CachedServicesTableFilterComposer,
    $$CachedServicesTableOrderingComposer,
    $$CachedServicesTableAnnotationComposer,
    $$CachedServicesTableCreateCompanionBuilder,
    $$CachedServicesTableUpdateCompanionBuilder,
    (
      CachedService,
      BaseReferences<_$AppDatabase, $CachedServicesTable, CachedService>
    ),
    CachedService,
    PrefetchHooks Function()> {
  $$CachedServicesTableTableManager(
      _$AppDatabase db, $CachedServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> categoryName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedServicesCompanion(
            id: id,
            name: name,
            description: description,
            price: price,
            durationMinutes: durationMinutes,
            imageUrl: imageUrl,
            categoryId: categoryId,
            categoryName: categoryName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required double price,
            required int durationMinutes,
            Value<String?> imageUrl = const Value.absent(),
            required String categoryId,
            Value<String?> categoryName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedServicesCompanion.insert(
            id: id,
            name: name,
            description: description,
            price: price,
            durationMinutes: durationMinutes,
            imageUrl: imageUrl,
            categoryId: categoryId,
            categoryName: categoryName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedServicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedServicesTable,
    CachedService,
    $$CachedServicesTableFilterComposer,
    $$CachedServicesTableOrderingComposer,
    $$CachedServicesTableAnnotationComposer,
    $$CachedServicesTableCreateCompanionBuilder,
    $$CachedServicesTableUpdateCompanionBuilder,
    (
      CachedService,
      BaseReferences<_$AppDatabase, $CachedServicesTable, CachedService>
    ),
    CachedService,
    PrefetchHooks Function()>;
typedef $$CachedBookingsTableCreateCompanionBuilder = CachedBookingsCompanion
    Function({
  required String id,
  required String serviceName,
  required double servicePrice,
  required String address,
  Value<String?> notes,
  required DateTime scheduledAt,
  required String status,
  Value<String?> providerName,
  Value<String?> customerName,
  Value<String?> chatRoomId,
  Value<int> rowid,
});
typedef $$CachedBookingsTableUpdateCompanionBuilder = CachedBookingsCompanion
    Function({
  Value<String> id,
  Value<String> serviceName,
  Value<double> servicePrice,
  Value<String> address,
  Value<String?> notes,
  Value<DateTime> scheduledAt,
  Value<String> status,
  Value<String?> providerName,
  Value<String?> customerName,
  Value<String?> chatRoomId,
  Value<int> rowid,
});

class $$CachedBookingsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBookingsTable> {
  $$CachedBookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get servicePrice => $composableBuilder(
      column: $table.servicePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnFilters(column));
}

class $$CachedBookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBookingsTable> {
  $$CachedBookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get servicePrice => $composableBuilder(
      column: $table.servicePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerName => $composableBuilder(
      column: $table.providerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnOrderings(column));
}

class $$CachedBookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBookingsTable> {
  $$CachedBookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => column);

  GeneratedColumn<double> get servicePrice => $composableBuilder(
      column: $table.servicePrice, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => column);
}

class $$CachedBookingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedBookingsTable,
    CachedBooking,
    $$CachedBookingsTableFilterComposer,
    $$CachedBookingsTableOrderingComposer,
    $$CachedBookingsTableAnnotationComposer,
    $$CachedBookingsTableCreateCompanionBuilder,
    $$CachedBookingsTableUpdateCompanionBuilder,
    (
      CachedBooking,
      BaseReferences<_$AppDatabase, $CachedBookingsTable, CachedBooking>
    ),
    CachedBooking,
    PrefetchHooks Function()> {
  $$CachedBookingsTableTableManager(
      _$AppDatabase db, $CachedBookingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serviceName = const Value.absent(),
            Value<double> servicePrice = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> providerName = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String?> chatRoomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBookingsCompanion(
            id: id,
            serviceName: serviceName,
            servicePrice: servicePrice,
            address: address,
            notes: notes,
            scheduledAt: scheduledAt,
            status: status,
            providerName: providerName,
            customerName: customerName,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serviceName,
            required double servicePrice,
            required String address,
            Value<String?> notes = const Value.absent(),
            required DateTime scheduledAt,
            required String status,
            Value<String?> providerName = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String?> chatRoomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBookingsCompanion.insert(
            id: id,
            serviceName: serviceName,
            servicePrice: servicePrice,
            address: address,
            notes: notes,
            scheduledAt: scheduledAt,
            status: status,
            providerName: providerName,
            customerName: customerName,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedBookingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedBookingsTable,
    CachedBooking,
    $$CachedBookingsTableFilterComposer,
    $$CachedBookingsTableOrderingComposer,
    $$CachedBookingsTableAnnotationComposer,
    $$CachedBookingsTableCreateCompanionBuilder,
    $$CachedBookingsTableUpdateCompanionBuilder,
    (
      CachedBooking,
      BaseReferences<_$AppDatabase, $CachedBookingsTable, CachedBooking>
    ),
    CachedBooking,
    PrefetchHooks Function()>;
typedef $$CachedMessagesTableCreateCompanionBuilder = CachedMessagesCompanion
    Function({
  required String id,
  required String chatRoomId,
  required String content,
  required String senderId,
  required String senderName,
  Value<String> messageType,
  required DateTime createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});
typedef $$CachedMessagesTableUpdateCompanionBuilder = CachedMessagesCompanion
    Function({
  Value<String> id,
  Value<String> chatRoomId,
  Value<String> content,
  Value<String> senderId,
  Value<String> senderName,
  Value<String> messageType,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});

class $$CachedMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$CachedMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$CachedMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedMessagesTable,
    CachedMessage,
    $$CachedMessagesTableFilterComposer,
    $$CachedMessagesTableOrderingComposer,
    $$CachedMessagesTableAnnotationComposer,
    $$CachedMessagesTableCreateCompanionBuilder,
    $$CachedMessagesTableUpdateCompanionBuilder,
    (
      CachedMessage,
      BaseReferences<_$AppDatabase, $CachedMessagesTable, CachedMessage>
    ),
    CachedMessage,
    PrefetchHooks Function()> {
  $$CachedMessagesTableTableManager(
      _$AppDatabase db, $CachedMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chatRoomId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> senderName = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMessagesCompanion(
            id: id,
            chatRoomId: chatRoomId,
            content: content,
            senderId: senderId,
            senderName: senderName,
            messageType: messageType,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chatRoomId,
            required String content,
            required String senderId,
            required String senderName,
            Value<String> messageType = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMessagesCompanion.insert(
            id: id,
            chatRoomId: chatRoomId,
            content: content,
            senderId: senderId,
            senderName: senderName,
            messageType: messageType,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedMessagesTable,
    CachedMessage,
    $$CachedMessagesTableFilterComposer,
    $$CachedMessagesTableOrderingComposer,
    $$CachedMessagesTableAnnotationComposer,
    $$CachedMessagesTableCreateCompanionBuilder,
    $$CachedMessagesTableUpdateCompanionBuilder,
    (
      CachedMessage,
      BaseReferences<_$AppDatabase, $CachedMessagesTable, CachedMessage>
    ),
    CachedMessage,
    PrefetchHooks Function()>;
typedef $$MessageRoomMetaTableCreateCompanionBuilder = MessageRoomMetaCompanion
    Function({
  required String chatRoomId,
  Value<bool> hasMoreOlder,
  Value<int> rowid,
});
typedef $$MessageRoomMetaTableUpdateCompanionBuilder = MessageRoomMetaCompanion
    Function({
  Value<String> chatRoomId,
  Value<bool> hasMoreOlder,
  Value<int> rowid,
});

class $$MessageRoomMetaTableFilterComposer
    extends Composer<_$AppDatabase, $MessageRoomMetaTable> {
  $$MessageRoomMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasMoreOlder => $composableBuilder(
      column: $table.hasMoreOlder, builder: (column) => ColumnFilters(column));
}

class $$MessageRoomMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageRoomMetaTable> {
  $$MessageRoomMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasMoreOlder => $composableBuilder(
      column: $table.hasMoreOlder,
      builder: (column) => ColumnOrderings(column));
}

class $$MessageRoomMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageRoomMetaTable> {
  $$MessageRoomMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => column);

  GeneratedColumn<bool> get hasMoreOlder => $composableBuilder(
      column: $table.hasMoreOlder, builder: (column) => column);
}

class $$MessageRoomMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageRoomMetaTable,
    MessageRoomMetaData,
    $$MessageRoomMetaTableFilterComposer,
    $$MessageRoomMetaTableOrderingComposer,
    $$MessageRoomMetaTableAnnotationComposer,
    $$MessageRoomMetaTableCreateCompanionBuilder,
    $$MessageRoomMetaTableUpdateCompanionBuilder,
    (
      MessageRoomMetaData,
      BaseReferences<_$AppDatabase, $MessageRoomMetaTable, MessageRoomMetaData>
    ),
    MessageRoomMetaData,
    PrefetchHooks Function()> {
  $$MessageRoomMetaTableTableManager(
      _$AppDatabase db, $MessageRoomMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageRoomMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageRoomMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageRoomMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chatRoomId = const Value.absent(),
            Value<bool> hasMoreOlder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageRoomMetaCompanion(
            chatRoomId: chatRoomId,
            hasMoreOlder: hasMoreOlder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String chatRoomId,
            Value<bool> hasMoreOlder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageRoomMetaCompanion.insert(
            chatRoomId: chatRoomId,
            hasMoreOlder: hasMoreOlder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessageRoomMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessageRoomMetaTable,
    MessageRoomMetaData,
    $$MessageRoomMetaTableFilterComposer,
    $$MessageRoomMetaTableOrderingComposer,
    $$MessageRoomMetaTableAnnotationComposer,
    $$MessageRoomMetaTableCreateCompanionBuilder,
    $$MessageRoomMetaTableUpdateCompanionBuilder,
    (
      MessageRoomMetaData,
      BaseReferences<_$AppDatabase, $MessageRoomMetaTable, MessageRoomMetaData>
    ),
    MessageRoomMetaData,
    PrefetchHooks Function()>;
typedef $$ChatRoomMappingsTableCreateCompanionBuilder
    = ChatRoomMappingsCompanion Function({
  required String bookingId,
  required String chatRoomId,
  Value<int> rowid,
});
typedef $$ChatRoomMappingsTableUpdateCompanionBuilder
    = ChatRoomMappingsCompanion Function({
  Value<String> bookingId,
  Value<String> chatRoomId,
  Value<int> rowid,
});

class $$ChatRoomMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatRoomMappingsTable> {
  $$ChatRoomMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookingId => $composableBuilder(
      column: $table.bookingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnFilters(column));
}

class $$ChatRoomMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatRoomMappingsTable> {
  $$ChatRoomMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookingId => $composableBuilder(
      column: $table.bookingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnOrderings(column));
}

class $$ChatRoomMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatRoomMappingsTable> {
  $$ChatRoomMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => column);
}

class $$ChatRoomMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatRoomMappingsTable,
    ChatRoomMapping,
    $$ChatRoomMappingsTableFilterComposer,
    $$ChatRoomMappingsTableOrderingComposer,
    $$ChatRoomMappingsTableAnnotationComposer,
    $$ChatRoomMappingsTableCreateCompanionBuilder,
    $$ChatRoomMappingsTableUpdateCompanionBuilder,
    (
      ChatRoomMapping,
      BaseReferences<_$AppDatabase, $ChatRoomMappingsTable, ChatRoomMapping>
    ),
    ChatRoomMapping,
    PrefetchHooks Function()> {
  $$ChatRoomMappingsTableTableManager(
      _$AppDatabase db, $ChatRoomMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatRoomMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatRoomMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatRoomMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookingId = const Value.absent(),
            Value<String> chatRoomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomMappingsCompanion(
            bookingId: bookingId,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookingId,
            required String chatRoomId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomMappingsCompanion.insert(
            bookingId: bookingId,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatRoomMappingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatRoomMappingsTable,
    ChatRoomMapping,
    $$ChatRoomMappingsTableFilterComposer,
    $$ChatRoomMappingsTableOrderingComposer,
    $$ChatRoomMappingsTableAnnotationComposer,
    $$ChatRoomMappingsTableCreateCompanionBuilder,
    $$ChatRoomMappingsTableUpdateCompanionBuilder,
    (
      ChatRoomMapping,
      BaseReferences<_$AppDatabase, $ChatRoomMappingsTable, ChatRoomMapping>
    ),
    ChatRoomMapping,
    PrefetchHooks Function()>;
typedef $$ChatInboxRowsTableCreateCompanionBuilder = ChatInboxRowsCompanion
    Function({
  required String bookingId,
  required String chatRoomId,
  required String serviceName,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<int> rowid,
});
typedef $$ChatInboxRowsTableUpdateCompanionBuilder = ChatInboxRowsCompanion
    Function({
  Value<String> bookingId,
  Value<String> chatRoomId,
  Value<String> serviceName,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<int> rowid,
});

class $$ChatInboxRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatInboxRowsTable> {
  $$ChatInboxRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookingId => $composableBuilder(
      column: $table.bookingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));
}

class $$ChatInboxRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatInboxRowsTable> {
  $$ChatInboxRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookingId => $composableBuilder(
      column: $table.bookingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));
}

class $$ChatInboxRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatInboxRowsTable> {
  $$ChatInboxRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get chatRoomId => $composableBuilder(
      column: $table.chatRoomId, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);
}

class $$ChatInboxRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatInboxRowsTable,
    ChatInboxRow,
    $$ChatInboxRowsTableFilterComposer,
    $$ChatInboxRowsTableOrderingComposer,
    $$ChatInboxRowsTableAnnotationComposer,
    $$ChatInboxRowsTableCreateCompanionBuilder,
    $$ChatInboxRowsTableUpdateCompanionBuilder,
    (
      ChatInboxRow,
      BaseReferences<_$AppDatabase, $ChatInboxRowsTable, ChatInboxRow>
    ),
    ChatInboxRow,
    PrefetchHooks Function()> {
  $$ChatInboxRowsTableTableManager(_$AppDatabase db, $ChatInboxRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatInboxRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatInboxRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatInboxRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookingId = const Value.absent(),
            Value<String> chatRoomId = const Value.absent(),
            Value<String> serviceName = const Value.absent(),
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatInboxRowsCompanion(
            bookingId: bookingId,
            chatRoomId: chatRoomId,
            serviceName: serviceName,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookingId,
            required String chatRoomId,
            required String serviceName,
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatInboxRowsCompanion.insert(
            bookingId: bookingId,
            chatRoomId: chatRoomId,
            serviceName: serviceName,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatInboxRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatInboxRowsTable,
    ChatInboxRow,
    $$ChatInboxRowsTableFilterComposer,
    $$ChatInboxRowsTableOrderingComposer,
    $$ChatInboxRowsTableAnnotationComposer,
    $$ChatInboxRowsTableCreateCompanionBuilder,
    $$ChatInboxRowsTableUpdateCompanionBuilder,
    (
      ChatInboxRow,
      BaseReferences<_$AppDatabase, $ChatInboxRowsTable, ChatInboxRow>
    ),
    ChatInboxRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedCategoriesTableTableManager get cachedCategories =>
      $$CachedCategoriesTableTableManager(_db, _db.cachedCategories);
  $$CachedServicesTableTableManager get cachedServices =>
      $$CachedServicesTableTableManager(_db, _db.cachedServices);
  $$CachedBookingsTableTableManager get cachedBookings =>
      $$CachedBookingsTableTableManager(_db, _db.cachedBookings);
  $$CachedMessagesTableTableManager get cachedMessages =>
      $$CachedMessagesTableTableManager(_db, _db.cachedMessages);
  $$MessageRoomMetaTableTableManager get messageRoomMeta =>
      $$MessageRoomMetaTableTableManager(_db, _db.messageRoomMeta);
  $$ChatRoomMappingsTableTableManager get chatRoomMappings =>
      $$ChatRoomMappingsTableTableManager(_db, _db.chatRoomMappings);
  $$ChatInboxRowsTableTableManager get chatInboxRows =>
      $$ChatInboxRowsTableTableManager(_db, _db.chatInboxRows);
}
