// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, color, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_utc'])!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final String name;
  final String? emoji;
  final String? color;
  final int createdAtUtc;
  const Activity(
      {required this.id,
      required this.name,
      this.emoji,
      this.color,
      required this.createdAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      name: Value(name),
      emoji:
          emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      color: serializer.fromJson<String?>(json['color']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'color': serializer.toJson<String?>(color),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
    };
  }

  Activity copyWith(
          {int? id,
          String? name,
          Value<String?> emoji = const Value.absent(),
          Value<String?> color = const Value.absent(),
          int? createdAtUtc}) =>
      Activity(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji.present ? emoji.value : this.emoji,
        color: color.present ? color.value : this.color,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, color, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.createdAtUtc == this.createdAtUtc);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<String?> color;
  final Value<int> createdAtUtc;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    required int createdAtUtc,
  })  : name = Value(name),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? color,
    Expression<int>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? emoji,
      Value<String?>? color,
      Value<int>? createdAtUtc}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES activities (id)'));
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<int> startUtc = GeneratedColumn<int>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<int> endUtc = GeneratedColumn<int>(
      'end_utc', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, activityId, startUtc, endUtc, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}activity_id'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_utc']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int activityId;
  final int startUtc;
  final int? endUtc;
  final String? note;
  const Session(
      {required this.id,
      required this.activityId,
      required this.startUtc,
      this.endUtc,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['start_utc'] = Variable<int>(startUtc);
    if (!nullToAbsent || endUtc != null) {
      map['end_utc'] = Variable<int>(endUtc);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      startUtc: Value(startUtc),
      endUtc:
          endUtc == null && nullToAbsent ? const Value.absent() : Value(endUtc),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      startUtc: serializer.fromJson<int>(json['startUtc']),
      endUtc: serializer.fromJson<int?>(json['endUtc']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'startUtc': serializer.toJson<int>(startUtc),
      'endUtc': serializer.toJson<int?>(endUtc),
      'note': serializer.toJson<String?>(note),
    };
  }

  Session copyWith(
          {int? id,
          int? activityId,
          int? startUtc,
          Value<int?> endUtc = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc.present ? endUtc.value : this.endUtc,
        note: note.present ? note.value : this.note,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, activityId, startUtc, endUtc, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.note == this.note);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<int> startUtc;
  final Value<int?> endUtc;
  final Value<String?> note;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.note = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    required int startUtc,
    this.endUtc = const Value.absent(),
    this.note = const Value.absent(),
  })  : activityId = Value(activityId),
        startUtc = Value(startUtc);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<int>? startUtc,
    Expression<int>? endUtc,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (note != null) 'note': note,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? activityId,
      Value<int>? startUtc,
      Value<int?>? endUtc,
      Value<String?>? note}) {
    return SessionsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<int>(endUtc.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PausesTable extends Pauses with TableInfo<$PausesTable, Pause> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<int> startUtc = GeneratedColumn<int>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<int> endUtc = GeneratedColumn<int>(
      'end_utc', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, startUtc, endUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pauses';
  @override
  VerificationContext validateIntegrity(Insertable<Pause> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pause map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pause(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_utc']),
    );
  }

  @override
  $PausesTable createAlias(String alias) {
    return $PausesTable(attachedDatabase, alias);
  }
}

class Pause extends DataClass implements Insertable<Pause> {
  final int id;
  final int sessionId;
  final int startUtc;
  final int? endUtc;
  const Pause(
      {required this.id,
      required this.sessionId,
      required this.startUtc,
      this.endUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['start_utc'] = Variable<int>(startUtc);
    if (!nullToAbsent || endUtc != null) {
      map['end_utc'] = Variable<int>(endUtc);
    }
    return map;
  }

  PausesCompanion toCompanion(bool nullToAbsent) {
    return PausesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      startUtc: Value(startUtc),
      endUtc:
          endUtc == null && nullToAbsent ? const Value.absent() : Value(endUtc),
    );
  }

  factory Pause.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pause(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      startUtc: serializer.fromJson<int>(json['startUtc']),
      endUtc: serializer.fromJson<int?>(json['endUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'startUtc': serializer.toJson<int>(startUtc),
      'endUtc': serializer.toJson<int?>(endUtc),
    };
  }

  Pause copyWith(
          {int? id,
          int? sessionId,
          int? startUtc,
          Value<int?> endUtc = const Value.absent()}) =>
      Pause(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc.present ? endUtc.value : this.endUtc,
      );
  Pause copyWithCompanion(PausesCompanion data) {
    return Pause(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pause(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, startUtc, endUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pause &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc);
}

class PausesCompanion extends UpdateCompanion<Pause> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> startUtc;
  final Value<int?> endUtc;
  const PausesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
  });
  PausesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int startUtc,
    this.endUtc = const Value.absent(),
  })  : sessionId = Value(sessionId),
        startUtc = Value(startUtc);
  static Insertable<Pause> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? startUtc,
    Expression<int>? endUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
    });
  }

  PausesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? startUtc,
      Value<int?>? endUtc}) {
    return PausesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<int>(endUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PausesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES activities (id)'));
  static const VerificationMeta _minutesPerWeekMeta =
      const VerificationMeta('minutesPerWeek');
  @override
  late final GeneratedColumn<int> minutesPerWeek = GeneratedColumn<int>(
      'minutes_per_week', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _daysPerWeekMeta =
      const VerificationMeta('daysPerWeek');
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
      'days_per_week', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minutesPerDayMeta =
      const VerificationMeta('minutesPerDay');
  @override
  late final GeneratedColumn<int> minutesPerDay = GeneratedColumn<int>(
      'minutes_per_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, activityId, minutesPerWeek, daysPerWeek, minutesPerDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('minutes_per_week')) {
      context.handle(
          _minutesPerWeekMeta,
          minutesPerWeek.isAcceptableOrUnknown(
              data['minutes_per_week']!, _minutesPerWeekMeta));
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
          _daysPerWeekMeta,
          daysPerWeek.isAcceptableOrUnknown(
              data['days_per_week']!, _daysPerWeekMeta));
    }
    if (data.containsKey('minutes_per_day')) {
      context.handle(
          _minutesPerDayMeta,
          minutesPerDay.isAcceptableOrUnknown(
              data['minutes_per_day']!, _minutesPerDayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}activity_id'])!,
      minutesPerWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes_per_week'])!,
      daysPerWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_per_week'])!,
      minutesPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes_per_day']),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final int activityId;
  final int minutesPerWeek;
  final int daysPerWeek;
  final int? minutesPerDay;
  const Goal(
      {required this.id,
      required this.activityId,
      required this.minutesPerWeek,
      required this.daysPerWeek,
      this.minutesPerDay});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['minutes_per_week'] = Variable<int>(minutesPerWeek);
    map['days_per_week'] = Variable<int>(daysPerWeek);
    if (!nullToAbsent || minutesPerDay != null) {
      map['minutes_per_day'] = Variable<int>(minutesPerDay);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      minutesPerWeek: Value(minutesPerWeek),
      daysPerWeek: Value(daysPerWeek),
      minutesPerDay: minutesPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesPerDay),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      minutesPerWeek: serializer.fromJson<int>(json['minutesPerWeek']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      minutesPerDay: serializer.fromJson<int?>(json['minutesPerDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'minutesPerWeek': serializer.toJson<int>(minutesPerWeek),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'minutesPerDay': serializer.toJson<int?>(minutesPerDay),
    };
  }

  Goal copyWith(
          {int? id,
          int? activityId,
          int? minutesPerWeek,
          int? daysPerWeek,
          Value<int?> minutesPerDay = const Value.absent()}) =>
      Goal(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        minutesPerWeek: minutesPerWeek ?? this.minutesPerWeek,
        daysPerWeek: daysPerWeek ?? this.daysPerWeek,
        minutesPerDay:
            minutesPerDay.present ? minutesPerDay.value : this.minutesPerDay,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      minutesPerWeek: data.minutesPerWeek.present
          ? data.minutesPerWeek.value
          : this.minutesPerWeek,
      daysPerWeek:
          data.daysPerWeek.present ? data.daysPerWeek.value : this.daysPerWeek,
      minutesPerDay: data.minutesPerDay.present
          ? data.minutesPerDay.value
          : this.minutesPerDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('minutesPerWeek: $minutesPerWeek, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('minutesPerDay: $minutesPerDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, activityId, minutesPerWeek, daysPerWeek, minutesPerDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.minutesPerWeek == this.minutesPerWeek &&
          other.daysPerWeek == this.daysPerWeek &&
          other.minutesPerDay == this.minutesPerDay);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<int> minutesPerWeek;
  final Value<int> daysPerWeek;
  final Value<int?> minutesPerDay;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.minutesPerWeek = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.minutesPerDay = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    this.minutesPerWeek = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.minutesPerDay = const Value.absent(),
  }) : activityId = Value(activityId);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<int>? minutesPerWeek,
    Expression<int>? daysPerWeek,
    Expression<int>? minutesPerDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (minutesPerWeek != null) 'minutes_per_week': minutesPerWeek,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (minutesPerDay != null) 'minutes_per_day': minutesPerDay,
    });
  }

  GoalsCompanion copyWith(
      {Value<int>? id,
      Value<int>? activityId,
      Value<int>? minutesPerWeek,
      Value<int>? daysPerWeek,
      Value<int?>? minutesPerDay}) {
    return GoalsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      minutesPerWeek: minutesPerWeek ?? this.minutesPerWeek,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      minutesPerDay: minutesPerDay ?? this.minutesPerDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (minutesPerWeek.present) {
      map['minutes_per_week'] = Variable<int>(minutesPerWeek.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (minutesPerDay.present) {
      map['minutes_per_day'] = Variable<int>(minutesPerDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('minutesPerWeek: $minutesPerWeek, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('minutesPerDay: $minutesPerDay')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $PausesTable pauses = $PausesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final ActivityDao activityDao = ActivityDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final PauseDao pauseDao = PauseDao(this as AppDatabase);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [activities, sessions, pauses, goals];
}

typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> emoji,
  Value<String?> color,
  required int createdAtUtc,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> emoji,
  Value<String?> color,
  Value<int> createdAtUtc,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName:
              $_aliasNameGenerator(db.activities.id, db.sessions.activityId));

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GoalsTable, List<Goal>> _goalsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.goals,
          aliasName:
              $_aliasNameGenerator(db.activities.id, db.goals.activityId));

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager($_db, $_db.goals)
        .filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> goalsRefs(
      Expression<bool> Function($$GoalsTableFilterComposer f) f) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableFilterComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(
      Expression<T> Function($$GoalsTableAnnotationComposer a) f) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goals,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalsTableAnnotationComposer(
              $db: $db,
              $table: $db.goals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, $$ActivitiesTableReferences),
    Activity,
    PrefetchHooks Function({bool sessionsRefs, bool goalsRefs})> {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> emoji = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int> createdAtUtc = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            createdAtUtc: createdAtUtc,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> emoji = const Value.absent(),
            Value<String?> color = const Value.absent(),
            required int createdAtUtc,
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            createdAtUtc: createdAtUtc,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActivitiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false, goalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionsRefs) db.sessions,
                if (goalsRefs) db.goals
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<Activity, $ActivitiesTable,
                            Session>(
                        currentTable: table,
                        referencedTable:
                            $$ActivitiesTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivitiesTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.activityId == item.id),
                        typedResults: items),
                  if (goalsRefs)
                    await $_getPrefetchedData<Activity, $ActivitiesTable, Goal>(
                        currentTable: table,
                        referencedTable:
                            $$ActivitiesTableReferences._goalsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivitiesTableReferences(db, table, p0)
                                .goalsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.activityId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, $$ActivitiesTableReferences),
    Activity,
    PrefetchHooks Function({bool sessionsRefs, bool goalsRefs})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required int activityId,
  required int startUtc,
  Value<int?> endUtc,
  Value<String?> note,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int> activityId,
  Value<int> startUtc,
  Value<int?> endUtc,
  Value<String?> note,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
          $_aliasNameGenerator(db.sessions.activityId, db.activities.id));

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$ActivitiesTableTableManager($_db, $_db.activities)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PausesTable, List<Pause>> _pausesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pauses,
          aliasName: $_aliasNameGenerator(db.sessions.id, db.pauses.sessionId));

  $$PausesTableProcessedTableManager get pausesRefs {
    final manager = $$PausesTableTableManager($_db, $_db.pauses)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pausesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableFilterComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> pausesRefs(
      Expression<bool> Function($$PausesTableFilterComposer f) f) {
    final $$PausesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pauses,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PausesTableFilterComposer(
              $db: $db,
              $table: $db.pauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableOrderingComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<int> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> pausesRefs<T extends Object>(
      Expression<T> Function($$PausesTableAnnotationComposer a) f) {
    final $$PausesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pauses,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PausesTableAnnotationComposer(
              $db: $db,
              $table: $db.pauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool activityId, bool pausesRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> activityId = const Value.absent(),
            Value<int> startUtc = const Value.absent(),
            Value<int?> endUtc = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            activityId: activityId,
            startUtc: startUtc,
            endUtc: endUtc,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int activityId,
            required int startUtc,
            Value<int?> endUtc = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            activityId: activityId,
            startUtc: startUtc,
            endUtc: endUtc,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({activityId = false, pausesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (pausesRefs) db.pauses],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (activityId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.activityId,
                    referencedTable:
                        $$SessionsTableReferences._activityIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._activityIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pausesRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Pause>(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._pausesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0).pausesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool activityId, bool pausesRefs})>;
typedef $$PausesTableCreateCompanionBuilder = PausesCompanion Function({
  Value<int> id,
  required int sessionId,
  required int startUtc,
  Value<int?> endUtc,
});
typedef $$PausesTableUpdateCompanionBuilder = PausesCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> startUtc,
  Value<int?> endUtc,
});

final class $$PausesTableReferences
    extends BaseReferences<_$AppDatabase, $PausesTable, Pause> {
  $$PausesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.pauses.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PausesTableFilterComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PausesTableOrderingComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<int> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PausesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PausesTable,
    Pause,
    $$PausesTableFilterComposer,
    $$PausesTableOrderingComposer,
    $$PausesTableAnnotationComposer,
    $$PausesTableCreateCompanionBuilder,
    $$PausesTableUpdateCompanionBuilder,
    (Pause, $$PausesTableReferences),
    Pause,
    PrefetchHooks Function({bool sessionId})> {
  $$PausesTableTableManager(_$AppDatabase db, $PausesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> startUtc = const Value.absent(),
            Value<int?> endUtc = const Value.absent(),
          }) =>
              PausesCompanion(
            id: id,
            sessionId: sessionId,
            startUtc: startUtc,
            endUtc: endUtc,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int startUtc,
            Value<int?> endUtc = const Value.absent(),
          }) =>
              PausesCompanion.insert(
            id: id,
            sessionId: sessionId,
            startUtc: startUtc,
            endUtc: endUtc,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PausesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$PausesTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$PausesTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PausesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PausesTable,
    Pause,
    $$PausesTableFilterComposer,
    $$PausesTableOrderingComposer,
    $$PausesTableAnnotationComposer,
    $$PausesTableCreateCompanionBuilder,
    $$PausesTableUpdateCompanionBuilder,
    (Pause, $$PausesTableReferences),
    Pause,
    PrefetchHooks Function({bool sessionId})>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required int activityId,
  Value<int> minutesPerWeek,
  Value<int> daysPerWeek,
  Value<int?> minutesPerDay,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<int> activityId,
  Value<int> minutesPerWeek,
  Value<int> daysPerWeek,
  Value<int?> minutesPerDay,
});

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) => db.activities
      .createAlias($_aliasNameGenerator(db.goals.activityId, db.activities.id));

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$ActivitiesTableTableManager($_db, $_db.activities)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutesPerWeek => $composableBuilder(
      column: $table.minutesPerWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutesPerDay => $composableBuilder(
      column: $table.minutesPerDay, builder: (column) => ColumnFilters(column));

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableFilterComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutesPerWeek => $composableBuilder(
      column: $table.minutesPerWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutesPerDay => $composableBuilder(
      column: $table.minutesPerDay,
      builder: (column) => ColumnOrderings(column));

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableOrderingComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minutesPerWeek => $composableBuilder(
      column: $table.minutesPerWeek, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => column);

  GeneratedColumn<int> get minutesPerDay => $composableBuilder(
      column: $table.minutesPerDay, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, $$GoalsTableReferences),
    Goal,
    PrefetchHooks Function({bool activityId})> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> activityId = const Value.absent(),
            Value<int> minutesPerWeek = const Value.absent(),
            Value<int> daysPerWeek = const Value.absent(),
            Value<int?> minutesPerDay = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            activityId: activityId,
            minutesPerWeek: minutesPerWeek,
            daysPerWeek: daysPerWeek,
            minutesPerDay: minutesPerDay,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int activityId,
            Value<int> minutesPerWeek = const Value.absent(),
            Value<int> daysPerWeek = const Value.absent(),
            Value<int?> minutesPerDay = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            activityId: activityId,
            minutesPerWeek: minutesPerWeek,
            daysPerWeek: daysPerWeek,
            minutesPerDay: minutesPerDay,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GoalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (activityId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.activityId,
                    referencedTable:
                        $$GoalsTableReferences._activityIdTable(db),
                    referencedColumn:
                        $$GoalsTableReferences._activityIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, $$GoalsTableReferences),
    Goal,
    PrefetchHooks Function({bool activityId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$PausesTableTableManager get pauses =>
      $$PausesTableTableManager(_db, _db.pauses);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
}

mixin _$ActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $ActivitiesTable get activities => attachedDatabase.activities;
}
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ActivitiesTable get activities => attachedDatabase.activities;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $PausesTable get pauses => attachedDatabase.pauses;
}
mixin _$PauseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ActivitiesTable get activities => attachedDatabase.activities;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $PausesTable get pauses => attachedDatabase.pauses;
}
mixin _$GoalDaoMixin on DatabaseAccessor<AppDatabase> {
  $ActivitiesTable get activities => attachedDatabase.activities;
  $GoalsTable get goals => attachedDatabase.goals;
}
