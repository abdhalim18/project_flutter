// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  const CategoryRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(id: Value(id), name: Value(name));
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryRow copyWith({String? id, String? name}) =>
      CategoryRow(id: id ?? this.id, name: name ?? this.name);
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    sku,
    price,
    stockQty,
    photoUrl,
    isActive,
    needsReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    } else if (isInserting) {
      context.missing(_stockQtyMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_qty'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String? categoryId;
  final String name;
  final String? sku;
  final double price;
  final int stockQty;
  final String? photoUrl;
  final bool isActive;
  final bool needsReview;
  const ProductRow({
    required this.id,
    this.categoryId,
    required this.name,
    this.sku,
    required this.price,
    required this.stockQty,
    this.photoUrl,
    required this.isActive,
    required this.needsReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    map['price'] = Variable<double>(price);
    map['stock_qty'] = Variable<int>(stockQty);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['needs_review'] = Variable<bool>(needsReview);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      price: Value(price),
      stockQty: Value(stockQty),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      isActive: Value(isActive),
      needsReview: Value(needsReview),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      price: serializer.fromJson<double>(json['price']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String?>(categoryId),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'price': serializer.toJson<double>(price),
      'stockQty': serializer.toJson<int>(stockQty),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'isActive': serializer.toJson<bool>(isActive),
      'needsReview': serializer.toJson<bool>(needsReview),
    };
  }

  ProductRow copyWith({
    String? id,
    Value<String?> categoryId = const Value.absent(),
    String? name,
    Value<String?> sku = const Value.absent(),
    double? price,
    int? stockQty,
    Value<String?> photoUrl = const Value.absent(),
    bool? isActive,
    bool? needsReview,
  }) => ProductRow(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    price: price ?? this.price,
    stockQty: stockQty ?? this.stockQty,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    isActive: isActive ?? this.isActive,
    needsReview: needsReview ?? this.needsReview,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      price: data.price.present ? data.price.value : this.price,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('price: $price, ')
          ..write('stockQty: $stockQty, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isActive: $isActive, ')
          ..write('needsReview: $needsReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    sku,
    price,
    stockQty,
    photoUrl,
    isActive,
    needsReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.price == this.price &&
          other.stockQty == this.stockQty &&
          other.photoUrl == this.photoUrl &&
          other.isActive == this.isActive &&
          other.needsReview == this.needsReview);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String?> categoryId;
  final Value<String> name;
  final Value<String?> sku;
  final Value<double> price;
  final Value<int> stockQty;
  final Value<String?> photoUrl;
  final Value<bool> isActive;
  final Value<bool> needsReview;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.price = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    this.categoryId = const Value.absent(),
    required String name,
    this.sku = const Value.absent(),
    required double price,
    required int stockQty,
    this.photoUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price),
       stockQty = Value(stockQty);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<double>? price,
    Expression<int>? stockQty,
    Expression<String>? photoUrl,
    Expression<bool>? isActive,
    Expression<bool>? needsReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (price != null) 'price': price,
      if (stockQty != null) 'stock_qty': stockQty,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isActive != null) 'is_active': isActive,
      if (needsReview != null) 'needs_review': needsReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String?>? categoryId,
    Value<String>? name,
    Value<String?>? sku,
    Value<double>? price,
    Value<int>? stockQty,
    Value<String?>? photoUrl,
    Value<bool>? isActive,
    Value<bool>? needsReview,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      needsReview: needsReview ?? this.needsReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('price: $price, ')
          ..write('stockQty: $stockQty, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isActive: $isActive, ')
          ..write('needsReview: $needsReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityKey, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPulledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityKey};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String entityKey;
  final DateTime lastPulledAt;
  const SyncMetaData({required this.entityKey, required this.lastPulledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_key'] = Variable<String>(entityKey);
    map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      entityKey: Value(entityKey),
      lastPulledAt: Value(lastPulledAt),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      entityKey: serializer.fromJson<String>(json['entityKey']),
      lastPulledAt: serializer.fromJson<DateTime>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityKey': serializer.toJson<String>(entityKey),
      'lastPulledAt': serializer.toJson<DateTime>(lastPulledAt),
    };
  }

  SyncMetaData copyWith({String? entityKey, DateTime? lastPulledAt}) =>
      SyncMetaData(
        entityKey: entityKey ?? this.entityKey,
        lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('entityKey: $entityKey, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityKey, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.entityKey == this.entityKey &&
          other.lastPulledAt == this.lastPulledAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> entityKey;
  final Value<DateTime> lastPulledAt;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.entityKey = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String entityKey,
    required DateTime lastPulledAt,
    this.rowid = const Value.absent(),
  }) : entityKey = Value(entityKey),
       lastPulledAt = Value(lastPulledAt);
  static Insertable<SyncMetaData> custom({
    Expression<String>? entityKey,
    Expression<DateTime>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityKey != null) 'entity_key': entityKey,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? entityKey,
    Value<DateTime>? lastPulledAt,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      entityKey: entityKey ?? this.entityKey,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('entityKey: $entityKey, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentReceivedMeta = const VerificationMeta(
    'paymentReceived',
  );
  @override
  late final GeneratedColumn<double> paymentReceived = GeneratedColumn<double>(
    'payment_received',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _clientCreatedAtMeta = const VerificationMeta(
    'clientCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientCreatedAt =
      GeneratedColumn<DateTime>(
        'client_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncAttemptCountMeta = const VerificationMeta(
    'syncAttemptCount',
  );
  @override
  late final GeneratedColumn<int> syncAttemptCount = GeneratedColumn<int>(
    'sync_attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cashierId,
    totalAmount,
    discountAmount,
    paymentMethod,
    paymentReceived,
    changeAmount,
    status,
    clientCreatedAt,
    syncState,
    syncAttemptCount,
    lastSyncError,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('payment_received')) {
      context.handle(
        _paymentReceivedMeta,
        paymentReceived.isAcceptableOrUnknown(
          data['payment_received']!,
          _paymentReceivedMeta,
        ),
      );
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('client_created_at')) {
      context.handle(
        _clientCreatedAtMeta,
        clientCreatedAt.isAcceptableOrUnknown(
          data['client_created_at']!,
          _clientCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientCreatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('sync_attempt_count')) {
      context.handle(
        _syncAttemptCountMeta,
        syncAttemptCount.isAcceptableOrUnknown(
          data['sync_attempt_count']!,
          _syncAttemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      paymentReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}payment_received'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      clientCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_created_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      syncAttemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_attempt_count'],
      )!,
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String cashierId;
  final double totalAmount;
  final double discountAmount;
  final String paymentMethod;
  final double paymentReceived;
  final double changeAmount;
  final String status;
  final DateTime clientCreatedAt;
  final String syncState;
  final int syncAttemptCount;
  final String? lastSyncError;
  final DateTime? lastAttemptAt;
  const TransactionRow({
    required this.id,
    required this.cashierId,
    required this.totalAmount,
    required this.discountAmount,
    required this.paymentMethod,
    required this.paymentReceived,
    required this.changeAmount,
    required this.status,
    required this.clientCreatedAt,
    required this.syncState,
    required this.syncAttemptCount,
    this.lastSyncError,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cashier_id'] = Variable<String>(cashierId);
    map['total_amount'] = Variable<double>(totalAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_received'] = Variable<double>(paymentReceived);
    map['change_amount'] = Variable<double>(changeAmount);
    map['status'] = Variable<String>(status);
    map['client_created_at'] = Variable<DateTime>(clientCreatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['sync_attempt_count'] = Variable<int>(syncAttemptCount);
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      cashierId: Value(cashierId),
      totalAmount: Value(totalAmount),
      discountAmount: Value(discountAmount),
      paymentMethod: Value(paymentMethod),
      paymentReceived: Value(paymentReceived),
      changeAmount: Value(changeAmount),
      status: Value(status),
      clientCreatedAt: Value(clientCreatedAt),
      syncState: Value(syncState),
      syncAttemptCount: Value(syncAttemptCount),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentReceived: serializer.fromJson<double>(json['paymentReceived']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      status: serializer.fromJson<String>(json['status']),
      clientCreatedAt: serializer.fromJson<DateTime>(json['clientCreatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      syncAttemptCount: serializer.fromJson<int>(json['syncAttemptCount']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cashierId': serializer.toJson<String>(cashierId),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentReceived': serializer.toJson<double>(paymentReceived),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'status': serializer.toJson<String>(status),
      'clientCreatedAt': serializer.toJson<DateTime>(clientCreatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'syncAttemptCount': serializer.toJson<int>(syncAttemptCount),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  TransactionRow copyWith({
    String? id,
    String? cashierId,
    double? totalAmount,
    double? discountAmount,
    String? paymentMethod,
    double? paymentReceived,
    double? changeAmount,
    String? status,
    DateTime? clientCreatedAt,
    String? syncState,
    int? syncAttemptCount,
    Value<String?> lastSyncError = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    cashierId: cashierId ?? this.cashierId,
    totalAmount: totalAmount ?? this.totalAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentReceived: paymentReceived ?? this.paymentReceived,
    changeAmount: changeAmount ?? this.changeAmount,
    status: status ?? this.status,
    clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
    syncState: syncState ?? this.syncState,
    syncAttemptCount: syncAttemptCount ?? this.syncAttemptCount,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentReceived: data.paymentReceived.present
          ? data.paymentReceived.value
          : this.paymentReceived,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      status: data.status.present ? data.status.value : this.status,
      clientCreatedAt: data.clientCreatedAt.present
          ? data.clientCreatedAt.value
          : this.clientCreatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      syncAttemptCount: data.syncAttemptCount.present
          ? data.syncAttemptCount.value
          : this.syncAttemptCount,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('cashierId: $cashierId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentReceived: $paymentReceived, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('status: $status, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('syncAttemptCount: $syncAttemptCount, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cashierId,
    totalAmount,
    discountAmount,
    paymentMethod,
    paymentReceived,
    changeAmount,
    status,
    clientCreatedAt,
    syncState,
    syncAttemptCount,
    lastSyncError,
    lastAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.cashierId == this.cashierId &&
          other.totalAmount == this.totalAmount &&
          other.discountAmount == this.discountAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentReceived == this.paymentReceived &&
          other.changeAmount == this.changeAmount &&
          other.status == this.status &&
          other.clientCreatedAt == this.clientCreatedAt &&
          other.syncState == this.syncState &&
          other.syncAttemptCount == this.syncAttemptCount &&
          other.lastSyncError == this.lastSyncError &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> cashierId;
  final Value<double> totalAmount;
  final Value<double> discountAmount;
  final Value<String> paymentMethod;
  final Value<double> paymentReceived;
  final Value<double> changeAmount;
  final Value<String> status;
  final Value<DateTime> clientCreatedAt;
  final Value<String> syncState;
  final Value<int> syncAttemptCount;
  final Value<String?> lastSyncError;
  final Value<DateTime?> lastAttemptAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentReceived = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.clientCreatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.syncAttemptCount = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String cashierId,
    required double totalAmount,
    this.discountAmount = const Value.absent(),
    required String paymentMethod,
    this.paymentReceived = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime clientCreatedAt,
    this.syncState = const Value.absent(),
    this.syncAttemptCount = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cashierId = Value(cashierId),
       totalAmount = Value(totalAmount),
       paymentMethod = Value(paymentMethod),
       clientCreatedAt = Value(clientCreatedAt);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? cashierId,
    Expression<double>? totalAmount,
    Expression<double>? discountAmount,
    Expression<String>? paymentMethod,
    Expression<double>? paymentReceived,
    Expression<double>? changeAmount,
    Expression<String>? status,
    Expression<DateTime>? clientCreatedAt,
    Expression<String>? syncState,
    Expression<int>? syncAttemptCount,
    Expression<String>? lastSyncError,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cashierId != null) 'cashier_id': cashierId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentReceived != null) 'payment_received': paymentReceived,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (status != null) 'status': status,
      if (clientCreatedAt != null) 'client_created_at': clientCreatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (syncAttemptCount != null) 'sync_attempt_count': syncAttemptCount,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? cashierId,
    Value<double>? totalAmount,
    Value<double>? discountAmount,
    Value<String>? paymentMethod,
    Value<double>? paymentReceived,
    Value<double>? changeAmount,
    Value<String>? status,
    Value<DateTime>? clientCreatedAt,
    Value<String>? syncState,
    Value<int>? syncAttemptCount,
    Value<String?>? lastSyncError,
    Value<DateTime?>? lastAttemptAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      cashierId: cashierId ?? this.cashierId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      syncState: syncState ?? this.syncState,
      syncAttemptCount: syncAttemptCount ?? this.syncAttemptCount,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentReceived.present) {
      map['payment_received'] = Variable<double>(paymentReceived.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (clientCreatedAt.present) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (syncAttemptCount.present) {
      map['sync_attempt_count'] = Variable<int>(syncAttemptCount.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('cashierId: $cashierId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentReceived: $paymentReceived, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('status: $status, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('syncAttemptCount: $syncAttemptCount, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemsTable extends TransactionItems
    with TableInfo<$TransactionItemsTable, TransactionItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    productId,
    productNameSnapshot,
    unitPrice,
    qty,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $TransactionItemsTable createAlias(String alias) {
    return $TransactionItemsTable(attachedDatabase, alias);
  }
}

class TransactionItemRow extends DataClass
    implements Insertable<TransactionItemRow> {
  final String id;
  final String transactionId;
  final String? productId;
  final String productNameSnapshot;
  final double unitPrice;
  final int qty;
  final double subtotal;
  const TransactionItemRow({
    required this.id,
    required this.transactionId,
    this.productId,
    required this.productNameSnapshot,
    required this.unitPrice,
    required this.qty,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['unit_price'] = Variable<double>(unitPrice);
    map['qty'] = Variable<int>(qty);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      unitPrice: Value(unitPrice),
      qty: Value(qty),
      subtotal: Value(subtotal),
    );
  }

  factory TransactionItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItemRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      productId: serializer.fromJson<String?>(json['productId']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      qty: serializer.fromJson<int>(json['qty']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'productId': serializer.toJson<String?>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'qty': serializer.toJson<int>(qty),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  TransactionItemRow copyWith({
    String? id,
    String? transactionId,
    Value<String?> productId = const Value.absent(),
    String? productNameSnapshot,
    double? unitPrice,
    int? qty,
    double? subtotal,
  }) => TransactionItemRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    productId: productId.present ? productId.value : this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    unitPrice: unitPrice ?? this.unitPrice,
    qty: qty ?? this.qty,
    subtotal: subtotal ?? this.subtotal,
  );
  TransactionItemRow copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItemRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      qty: data.qty.present ? data.qty.value : this.qty,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('qty: $qty, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    productId,
    productNameSnapshot,
    unitPrice,
    qty,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.unitPrice == this.unitPrice &&
          other.qty == this.qty &&
          other.subtotal == this.subtotal);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItemRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> productId;
  final Value<String> productNameSnapshot;
  final Value<double> unitPrice;
  final Value<int> qty;
  final Value<double> subtotal;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.qty = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required String id,
    required String transactionId,
    this.productId = const Value.absent(),
    required String productNameSnapshot,
    required double unitPrice,
    required int qty,
    required double subtotal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       productNameSnapshot = Value(productNameSnapshot),
       unitPrice = Value(unitPrice),
       qty = Value(qty),
       subtotal = Value(subtotal);
  static Insertable<TransactionItemRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? productId,
    Expression<String>? productNameSnapshot,
    Expression<double>? unitPrice,
    Expression<int>? qty,
    Expression<double>? subtotal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (qty != null) 'qty': qty,
      if (subtotal != null) 'subtotal': subtotal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String?>? productId,
    Value<String>? productNameSnapshot,
    Value<double>? unitPrice,
    Value<int>? qty,
    Value<double>? subtotal,
    Value<int>? rowid,
  }) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('qty: $qty, ')
          ..write('subtotal: $subtotal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeQtyMeta = const VerificationMeta(
    'changeQty',
  );
  @override
  late final GeneratedColumn<int> changeQty = GeneratedColumn<int>(
    'change_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    changeQty,
    reason,
    referenceId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('change_qty')) {
      context.handle(
        _changeQtyMeta,
        changeQty.isAcceptableOrUnknown(data['change_qty']!, _changeQtyMeta),
      );
    } else if (isInserting) {
      context.missing(_changeQtyMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      changeQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_qty'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final String id;
  final String productId;
  final int changeQty;
  final String reason;
  final String? referenceId;
  final DateTime createdAt;
  const StockMovementRow({
    required this.id,
    required this.productId,
    required this.changeQty,
    required this.reason,
    this.referenceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['change_qty'] = Variable<int>(changeQty);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      changeQty: Value(changeQty),
      reason: Value(reason),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      changeQty: serializer.fromJson<int>(json['changeQty']),
      reason: serializer.fromJson<String>(json['reason']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'changeQty': serializer.toJson<int>(changeQty),
      'reason': serializer.toJson<String>(reason),
      'referenceId': serializer.toJson<String?>(referenceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovementRow copyWith({
    String? id,
    String? productId,
    int? changeQty,
    String? reason,
    Value<String?> referenceId = const Value.absent(),
    DateTime? createdAt,
  }) => StockMovementRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    changeQty: changeQty ?? this.changeQty,
    reason: reason ?? this.reason,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      changeQty: data.changeQty.present ? data.changeQty.value : this.changeQty,
      reason: data.reason.present ? data.reason.value : this.reason,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('changeQty: $changeQty, ')
          ..write('reason: $reason, ')
          ..write('referenceId: $referenceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, changeQty, reason, referenceId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.changeQty == this.changeQty &&
          other.reason == this.reason &&
          other.referenceId == this.referenceId &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<int> changeQty;
  final Value<String> reason;
  final Value<String?> referenceId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.changeQty = const Value.absent(),
    this.reason = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required int changeQty,
    required String reason,
    this.referenceId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       changeQty = Value(changeQty),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<int>? changeQty,
    Expression<String>? reason,
    Expression<String>? referenceId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (changeQty != null) 'change_qty': changeQty,
      if (reason != null) 'reason': reason,
      if (referenceId != null) 'reference_id': referenceId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<int>? changeQty,
    Value<String>? reason,
    Value<String?>? referenceId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      changeQty: changeQty ?? this.changeQty,
      reason: reason ?? this.reason,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (changeQty.present) {
      map['change_qty'] = Variable<int>(changeQty.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('changeQty: $changeQty, ')
          ..write('reason: $reason, ')
          ..write('referenceId: $referenceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionItemsTable transactionItems = $TransactionItemsTable(
    this,
  );
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    products,
    syncMeta,
    transactions,
    transactionItems,
    stockMovements,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) =>
                  CategoriesCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      Value<String?> categoryId,
      required String name,
      Value<String?> sku,
      required double price,
      required int stockQty,
      Value<String?> photoUrl,
      Value<bool> isActive,
      Value<bool> needsReview,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String?> categoryId,
      Value<String> name,
      Value<String?> sku,
      Value<double> price,
      Value<int> stockQty,
      Value<String?> photoUrl,
      Value<bool> isActive,
      Value<bool> needsReview,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                sku: sku,
                price: price,
                stockQty: stockQty,
                photoUrl: photoUrl,
                isActive: isActive,
                needsReview: needsReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> categoryId = const Value.absent(),
                required String name,
                Value<String?> sku = const Value.absent(),
                required double price,
                required int stockQty,
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                sku: sku,
                price: price,
                stockQty: stockQty,
                photoUrl: photoUrl,
                isActive: isActive,
                needsReview: needsReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String entityKey,
      required DateTime lastPulledAt,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> entityKey,
      Value<DateTime> lastPulledAt,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityKey = const Value.absent(),
                Value<DateTime> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(
                entityKey: entityKey,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityKey,
                required DateTime lastPulledAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                entityKey: entityKey,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String cashierId,
      required double totalAmount,
      Value<double> discountAmount,
      required String paymentMethod,
      Value<double> paymentReceived,
      Value<double> changeAmount,
      Value<String> status,
      required DateTime clientCreatedAt,
      Value<String> syncState,
      Value<int> syncAttemptCount,
      Value<String?> lastSyncError,
      Value<DateTime?> lastAttemptAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> cashierId,
      Value<double> totalAmount,
      Value<double> discountAmount,
      Value<String> paymentMethod,
      Value<double> paymentReceived,
      Value<double> changeAmount,
      Value<String> status,
      Value<DateTime> clientCreatedAt,
      Value<String> syncState,
      Value<int> syncAttemptCount,
      Value<String?> lastSyncError,
      Value<DateTime?> lastAttemptAt,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paymentReceived => $composableBuilder(
    column: $table.paymentReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncAttemptCount => $composableBuilder(
    column: $table.syncAttemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paymentReceived => $composableBuilder(
    column: $table.paymentReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncAttemptCount => $composableBuilder(
    column: $table.syncAttemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paymentReceived => $composableBuilder(
    column: $table.paymentReceived,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get syncAttemptCount => $composableBuilder(
    column: $table.syncAttemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<double> paymentReceived = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> clientCreatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> syncAttemptCount = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                cashierId: cashierId,
                totalAmount: totalAmount,
                discountAmount: discountAmount,
                paymentMethod: paymentMethod,
                paymentReceived: paymentReceived,
                changeAmount: changeAmount,
                status: status,
                clientCreatedAt: clientCreatedAt,
                syncState: syncState,
                syncAttemptCount: syncAttemptCount,
                lastSyncError: lastSyncError,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cashierId,
                required double totalAmount,
                Value<double> discountAmount = const Value.absent(),
                required String paymentMethod,
                Value<double> paymentReceived = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime clientCreatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> syncAttemptCount = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                cashierId: cashierId,
                totalAmount: totalAmount,
                discountAmount: discountAmount,
                paymentMethod: paymentMethod,
                paymentReceived: paymentReceived,
                changeAmount: changeAmount,
                status: status,
                clientCreatedAt: clientCreatedAt,
                syncState: syncState,
                syncAttemptCount: syncAttemptCount,
                lastSyncError: lastSyncError,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionItemsTableCreateCompanionBuilder =
    TransactionItemsCompanion Function({
      required String id,
      required String transactionId,
      Value<String?> productId,
      required String productNameSnapshot,
      required double unitPrice,
      required int qty,
      required double subtotal,
      Value<int> rowid,
    });
typedef $$TransactionItemsTableUpdateCompanionBuilder =
    TransactionItemsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String?> productId,
      Value<String> productNameSnapshot,
      Value<double> unitPrice,
      Value<int> qty,
      Value<double> subtotal,
      Value<int> rowid,
    });

class $$TransactionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);
}

class $$TransactionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionItemsTable,
          TransactionItemRow,
          $$TransactionItemsTableFilterComposer,
          $$TransactionItemsTableOrderingComposer,
          $$TransactionItemsTableAnnotationComposer,
          $$TransactionItemsTableCreateCompanionBuilder,
          $$TransactionItemsTableUpdateCompanionBuilder,
          (
            TransactionItemRow,
            BaseReferences<
              _$AppDatabase,
              $TransactionItemsTable,
              TransactionItemRow
            >,
          ),
          TransactionItemRow,
          PrefetchHooks Function()
        > {
  $$TransactionItemsTableTableManager(
    _$AppDatabase db,
    $TransactionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                unitPrice: unitPrice,
                qty: qty,
                subtotal: subtotal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                Value<String?> productId = const Value.absent(),
                required String productNameSnapshot,
                required double unitPrice,
                required int qty,
                required double subtotal,
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion.insert(
                id: id,
                transactionId: transactionId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                unitPrice: unitPrice,
                qty: qty,
                subtotal: subtotal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionItemsTable,
      TransactionItemRow,
      $$TransactionItemsTableFilterComposer,
      $$TransactionItemsTableOrderingComposer,
      $$TransactionItemsTableAnnotationComposer,
      $$TransactionItemsTableCreateCompanionBuilder,
      $$TransactionItemsTableUpdateCompanionBuilder,
      (
        TransactionItemRow,
        BaseReferences<
          _$AppDatabase,
          $TransactionItemsTable,
          TransactionItemRow
        >,
      ),
      TransactionItemRow,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String productId,
      required int changeQty,
      required String reason,
      Value<String?> referenceId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<int> changeQty,
      Value<String> reason,
      Value<String?> referenceId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeQty => $composableBuilder(
    column: $table.changeQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeQty => $composableBuilder(
    column: $table.changeQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get changeQty =>
      $composableBuilder(column: $table.changeQty, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovementRow,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovementRow,
            BaseReferences<
              _$AppDatabase,
              $StockMovementsTable,
              StockMovementRow
            >,
          ),
          StockMovementRow,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> changeQty = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                changeQty: changeQty,
                reason: reason,
                referenceId: referenceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required int changeQty,
                required String reason,
                Value<String?> referenceId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                changeQty: changeQty,
                reason: reason,
                referenceId: referenceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovementRow,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovementRow,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>,
      ),
      StockMovementRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionItemsTableTableManager get transactionItems =>
      $$TransactionItemsTableTableManager(_db, _db.transactionItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
}
