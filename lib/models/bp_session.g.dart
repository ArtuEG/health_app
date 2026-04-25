// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bp_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBPSessionCollection on Isar {
  IsarCollection<BPSession> get bPSessions => this.collection();
}

const BPSessionSchema = CollectionSchema(
  name: r'BPSession',
  id: -5576920939963420906,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'leftArm': PropertySchema(
      id: 1,
      name: r'leftArm',
      type: IsarType.object,
      target: r'ArmReading',
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    ),
    r'rightArm': PropertySchema(
      id: 3,
      name: r'rightArm',
      type: IsarType.object,
      target: r'ArmReading',
    )
  },
  estimateSize: _bPSessionEstimateSize,
  serialize: _bPSessionSerialize,
  deserialize: _bPSessionDeserialize,
  deserializeProp: _bPSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'ArmReading': ArmReadingSchema},
  getId: _bPSessionGetId,
  getLinks: _bPSessionGetLinks,
  attach: _bPSessionAttach,
  version: '3.1.0+1',
);

int _bPSessionEstimateSize(
  BPSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      ArmReadingSchema.estimateSize(
          object.leftArm, allOffsets[ArmReading]!, allOffsets);
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 +
      ArmReadingSchema.estimateSize(
          object.rightArm, allOffsets[ArmReading]!, allOffsets);
  return bytesCount;
}

void _bPSessionSerialize(
  BPSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
  writer.writeObject<ArmReading>(
    offsets[1],
    allOffsets,
    ArmReadingSchema.serialize,
    object.leftArm,
  );
  writer.writeString(offsets[2], object.note);
  writer.writeObject<ArmReading>(
    offsets[3],
    allOffsets,
    ArmReadingSchema.serialize,
    object.rightArm,
  );
}

BPSession _bPSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BPSession();
  object.dateTime = reader.readDateTime(offsets[0]);
  object.id = id;
  object.leftArm = reader.readObjectOrNull<ArmReading>(
        offsets[1],
        ArmReadingSchema.deserialize,
        allOffsets,
      ) ??
      ArmReading();
  object.note = reader.readStringOrNull(offsets[2]);
  object.rightArm = reader.readObjectOrNull<ArmReading>(
        offsets[3],
        ArmReadingSchema.deserialize,
        allOffsets,
      ) ??
      ArmReading();
  return object;
}

P _bPSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<ArmReading>(
            offset,
            ArmReadingSchema.deserialize,
            allOffsets,
          ) ??
          ArmReading()) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readObjectOrNull<ArmReading>(
            offset,
            ArmReadingSchema.deserialize,
            allOffsets,
          ) ??
          ArmReading()) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bPSessionGetId(BPSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bPSessionGetLinks(BPSession object) {
  return [];
}

void _bPSessionAttach(IsarCollection<dynamic> col, Id id, BPSession object) {
  object.id = id;
}

extension BPSessionQueryWhereSort
    on QueryBuilder<BPSession, BPSession, QWhere> {
  QueryBuilder<BPSession, BPSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BPSessionQueryWhere
    on QueryBuilder<BPSession, BPSession, QWhereClause> {
  QueryBuilder<BPSession, BPSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BPSessionQueryFilter
    on QueryBuilder<BPSession, BPSession, QFilterCondition> {
  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> dateTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }
}

extension BPSessionQueryObject
    on QueryBuilder<BPSession, BPSession, QFilterCondition> {
  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> leftArm(
      FilterQuery<ArmReading> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'leftArm');
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterFilterCondition> rightArm(
      FilterQuery<ArmReading> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'rightArm');
    });
  }
}

extension BPSessionQueryLinks
    on QueryBuilder<BPSession, BPSession, QFilterCondition> {}

extension BPSessionQuerySortBy on QueryBuilder<BPSession, BPSession, QSortBy> {
  QueryBuilder<BPSession, BPSession, QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension BPSessionQuerySortThenBy
    on QueryBuilder<BPSession, BPSession, QSortThenBy> {
  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BPSession, BPSession, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension BPSessionQueryWhereDistinct
    on QueryBuilder<BPSession, BPSession, QDistinct> {
  QueryBuilder<BPSession, BPSession, QDistinct> distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<BPSession, BPSession, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }
}

extension BPSessionQueryProperty
    on QueryBuilder<BPSession, BPSession, QQueryProperty> {
  QueryBuilder<BPSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BPSession, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<BPSession, ArmReading, QQueryOperations> leftArmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leftArm');
    });
  }

  QueryBuilder<BPSession, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<BPSession, ArmReading, QQueryOperations> rightArmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rightArm');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ArmReadingSchema = Schema(
  name: r'ArmReading',
  id: 1056414429284039559,
  properties: {
    r'dia': PropertySchema(
      id: 0,
      name: r'dia',
      type: IsarType.long,
    ),
    r'pulse': PropertySchema(
      id: 1,
      name: r'pulse',
      type: IsarType.long,
    ),
    r'sys': PropertySchema(
      id: 2,
      name: r'sys',
      type: IsarType.long,
    )
  },
  estimateSize: _armReadingEstimateSize,
  serialize: _armReadingSerialize,
  deserialize: _armReadingDeserialize,
  deserializeProp: _armReadingDeserializeProp,
);

int _armReadingEstimateSize(
  ArmReading object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _armReadingSerialize(
  ArmReading object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dia);
  writer.writeLong(offsets[1], object.pulse);
  writer.writeLong(offsets[2], object.sys);
}

ArmReading _armReadingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArmReading();
  object.dia = reader.readLong(offsets[0]);
  object.pulse = reader.readLong(offsets[1]);
  object.sys = reader.readLong(offsets[2]);
  return object;
}

P _armReadingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ArmReadingQueryFilter
    on QueryBuilder<ArmReading, ArmReading, QFilterCondition> {
  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> diaEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dia',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> diaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dia',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> diaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dia',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> diaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> pulseEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pulse',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> pulseGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pulse',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> pulseLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pulse',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> pulseBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pulse',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> sysEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sys',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> sysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sys',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> sysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sys',
        value: value,
      ));
    });
  }

  QueryBuilder<ArmReading, ArmReading, QAfterFilterCondition> sysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArmReadingQueryObject
    on QueryBuilder<ArmReading, ArmReading, QFilterCondition> {}
