// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glucose_measurement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGlucoseMeasurementCollection on Isar {
  IsarCollection<GlucoseMeasurement> get glucoseMeasurements =>
      this.collection();
}

const GlucoseMeasurementSchema = CollectionSchema(
  name: r'GlucoseMeasurement',
  id: -3219243613285824044,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'mgPerDl': PropertySchema(
      id: 1,
      name: r'mgPerDl',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(
      id: 2,
      name: r'notes',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.byte,
      enumMap: _GlucoseMeasurementtypeEnumValueMap,
    )
  },
  estimateSize: _glucoseMeasurementEstimateSize,
  serialize: _glucoseMeasurementSerialize,
  deserialize: _glucoseMeasurementDeserialize,
  deserializeProp: _glucoseMeasurementDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _glucoseMeasurementGetId,
  getLinks: _glucoseMeasurementGetLinks,
  attach: _glucoseMeasurementAttach,
  version: '3.1.0+1',
);

int _glucoseMeasurementEstimateSize(
  GlucoseMeasurement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _glucoseMeasurementSerialize(
  GlucoseMeasurement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
  writer.writeLong(offsets[1], object.mgPerDl);
  writer.writeString(offsets[2], object.notes);
  writer.writeByte(offsets[3], object.type.index);
}

GlucoseMeasurement _glucoseMeasurementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GlucoseMeasurement();
  object.dateTime = reader.readDateTime(offsets[0]);
  object.id = id;
  object.mgPerDl = reader.readLong(offsets[1]);
  object.notes = reader.readStringOrNull(offsets[2]);
  object.type =
      _GlucoseMeasurementtypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          GlucoseType.fasting;
  return object;
}

P _glucoseMeasurementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (_GlucoseMeasurementtypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          GlucoseType.fasting) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GlucoseMeasurementtypeEnumValueMap = {
  'fasting': 0,
  'postprandial': 1,
  'other': 2,
};
const _GlucoseMeasurementtypeValueEnumMap = {
  0: GlucoseType.fasting,
  1: GlucoseType.postprandial,
  2: GlucoseType.other,
};

Id _glucoseMeasurementGetId(GlucoseMeasurement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _glucoseMeasurementGetLinks(
    GlucoseMeasurement object) {
  return [];
}

void _glucoseMeasurementAttach(
    IsarCollection<dynamic> col, Id id, GlucoseMeasurement object) {
  object.id = id;
}

extension GlucoseMeasurementQueryWhereSort
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QWhere> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GlucoseMeasurementQueryWhere
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QWhereClause> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterWhereClause>
      idBetween(
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

extension GlucoseMeasurementQueryFilter
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QFilterCondition> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      dateTimeGreaterThan(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      dateTimeLessThan(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      dateTimeBetween(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      mgPerDlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mgPerDl',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      mgPerDlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mgPerDl',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      mgPerDlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mgPerDl',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      mgPerDlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mgPerDl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      typeEqualTo(GlucoseType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      typeGreaterThan(
    GlucoseType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      typeLessThan(
    GlucoseType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterFilterCondition>
      typeBetween(
    GlucoseType lower,
    GlucoseType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GlucoseMeasurementQueryObject
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QFilterCondition> {}

extension GlucoseMeasurementQueryLinks
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QFilterCondition> {}

extension GlucoseMeasurementQuerySortBy
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QSortBy> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByMgPerDl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mgPerDl', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByMgPerDlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mgPerDl', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension GlucoseMeasurementQuerySortThenBy
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QSortThenBy> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByMgPerDl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mgPerDl', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByMgPerDlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mgPerDl', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension GlucoseMeasurementQueryWhereDistinct
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QDistinct> {
  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QDistinct>
      distinctByMgPerDl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mgPerDl');
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension GlucoseMeasurementQueryProperty
    on QueryBuilder<GlucoseMeasurement, GlucoseMeasurement, QQueryProperty> {
  QueryBuilder<GlucoseMeasurement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GlucoseMeasurement, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<GlucoseMeasurement, int, QQueryOperations> mgPerDlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mgPerDl');
    });
  }

  QueryBuilder<GlucoseMeasurement, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<GlucoseMeasurement, GlucoseType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
