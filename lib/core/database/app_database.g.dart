// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentWeightKgMeta = const VerificationMeta(
    'currentWeightKg',
  );
  @override
  late final GeneratedColumn<double> currentWeightKg = GeneratedColumn<double>(
    'current_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyRateKgMeta = const VerificationMeta(
    'weeklyRateKg',
  );
  @override
  late final GeneratedColumn<double> weeklyRateKg = GeneratedColumn<double>(
    'weekly_rate_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _targetCaloriesMeta = const VerificationMeta(
    'targetCalories',
  );
  @override
  late final GeneratedColumn<int> targetCalories = GeneratedColumn<int>(
    'target_calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetProteinGMeta = const VerificationMeta(
    'targetProteinG',
  );
  @override
  late final GeneratedColumn<double> targetProteinG = GeneratedColumn<double>(
    'target_protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetFatGMeta = const VerificationMeta(
    'targetFatG',
  );
  @override
  late final GeneratedColumn<double> targetFatG = GeneratedColumn<double>(
    'target_fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCarbsGMeta = const VerificationMeta(
    'targetCarbsG',
  );
  @override
  late final GeneratedColumn<double> targetCarbsG = GeneratedColumn<double>(
    'target_carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWaterMlMeta = const VerificationMeta(
    'targetWaterMl',
  );
  @override
  late final GeneratedColumn<int> targetWaterMl = GeneratedColumn<int>(
    'target_water_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    gender,
    heightCm,
    currentWeightKg,
    targetWeightKg,
    activityLevel,
    goalType,
    weeklyRateKg,
    targetCalories,
    targetProteinG,
    targetFatG,
    targetCarbsG,
    targetWaterMl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('current_weight_kg')) {
      context.handle(
        _currentWeightKgMeta,
        currentWeightKg.isAcceptableOrUnknown(
          data['current_weight_kg']!,
          _currentWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentWeightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightKgMeta);
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityLevelMeta);
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('weekly_rate_kg')) {
      context.handle(
        _weeklyRateKgMeta,
        weeklyRateKg.isAcceptableOrUnknown(
          data['weekly_rate_kg']!,
          _weeklyRateKgMeta,
        ),
      );
    }
    if (data.containsKey('target_calories')) {
      context.handle(
        _targetCaloriesMeta,
        targetCalories.isAcceptableOrUnknown(
          data['target_calories']!,
          _targetCaloriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCaloriesMeta);
    }
    if (data.containsKey('target_protein_g')) {
      context.handle(
        _targetProteinGMeta,
        targetProteinG.isAcceptableOrUnknown(
          data['target_protein_g']!,
          _targetProteinGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetProteinGMeta);
    }
    if (data.containsKey('target_fat_g')) {
      context.handle(
        _targetFatGMeta,
        targetFatG.isAcceptableOrUnknown(
          data['target_fat_g']!,
          _targetFatGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetFatGMeta);
    }
    if (data.containsKey('target_carbs_g')) {
      context.handle(
        _targetCarbsGMeta,
        targetCarbsG.isAcceptableOrUnknown(
          data['target_carbs_g']!,
          _targetCarbsGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCarbsGMeta);
    }
    if (data.containsKey('target_water_ml')) {
      context.handle(
        _targetWaterMlMeta,
        targetWaterMl.isAcceptableOrUnknown(
          data['target_water_ml']!,
          _targetWaterMlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWaterMlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      currentWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      )!,
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      weeklyRateKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_rate_kg'],
      )!,
      targetCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_calories'],
      )!,
      targetProteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_protein_g'],
      )!,
      targetFatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_fat_g'],
      )!,
      targetCarbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_carbs_g'],
      )!,
      targetWaterMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_water_ml'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String activityLevel;
  final String goalType;
  final double weeklyRateKg;
  final int targetCalories;
  final double targetProteinG;
  final double targetFatG;
  final double targetCarbsG;
  final int targetWaterMl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.activityLevel,
    required this.goalType,
    required this.weeklyRateKg,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetFatG,
    required this.targetCarbsG,
    required this.targetWaterMl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['gender'] = Variable<String>(gender);
    map['height_cm'] = Variable<double>(heightCm);
    map['current_weight_kg'] = Variable<double>(currentWeightKg);
    map['target_weight_kg'] = Variable<double>(targetWeightKg);
    map['activity_level'] = Variable<String>(activityLevel);
    map['goal_type'] = Variable<String>(goalType);
    map['weekly_rate_kg'] = Variable<double>(weeklyRateKg);
    map['target_calories'] = Variable<int>(targetCalories);
    map['target_protein_g'] = Variable<double>(targetProteinG);
    map['target_fat_g'] = Variable<double>(targetFatG);
    map['target_carbs_g'] = Variable<double>(targetCarbsG);
    map['target_water_ml'] = Variable<int>(targetWaterMl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: Value(birthDate),
      gender: Value(gender),
      heightCm: Value(heightCm),
      currentWeightKg: Value(currentWeightKg),
      targetWeightKg: Value(targetWeightKg),
      activityLevel: Value(activityLevel),
      goalType: Value(goalType),
      weeklyRateKg: Value(weeklyRateKg),
      targetCalories: Value(targetCalories),
      targetProteinG: Value(targetProteinG),
      targetFatG: Value(targetFatG),
      targetCarbsG: Value(targetCarbsG),
      targetWaterMl: Value(targetWaterMl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      gender: serializer.fromJson<String>(json['gender']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      currentWeightKg: serializer.fromJson<double>(json['currentWeightKg']),
      targetWeightKg: serializer.fromJson<double>(json['targetWeightKg']),
      activityLevel: serializer.fromJson<String>(json['activityLevel']),
      goalType: serializer.fromJson<String>(json['goalType']),
      weeklyRateKg: serializer.fromJson<double>(json['weeklyRateKg']),
      targetCalories: serializer.fromJson<int>(json['targetCalories']),
      targetProteinG: serializer.fromJson<double>(json['targetProteinG']),
      targetFatG: serializer.fromJson<double>(json['targetFatG']),
      targetCarbsG: serializer.fromJson<double>(json['targetCarbsG']),
      targetWaterMl: serializer.fromJson<int>(json['targetWaterMl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'gender': serializer.toJson<String>(gender),
      'heightCm': serializer.toJson<double>(heightCm),
      'currentWeightKg': serializer.toJson<double>(currentWeightKg),
      'targetWeightKg': serializer.toJson<double>(targetWeightKg),
      'activityLevel': serializer.toJson<String>(activityLevel),
      'goalType': serializer.toJson<String>(goalType),
      'weeklyRateKg': serializer.toJson<double>(weeklyRateKg),
      'targetCalories': serializer.toJson<int>(targetCalories),
      'targetProteinG': serializer.toJson<double>(targetProteinG),
      'targetFatG': serializer.toJson<double>(targetFatG),
      'targetCarbsG': serializer.toJson<double>(targetCarbsG),
      'targetWaterMl': serializer.toJson<int>(targetWaterMl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? goalType,
    double? weeklyRateKg,
    int? targetCalories,
    double? targetProteinG,
    double? targetFatG,
    double? targetCarbsG,
    int? targetWaterMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    gender: gender ?? this.gender,
    heightCm: heightCm ?? this.heightCm,
    currentWeightKg: currentWeightKg ?? this.currentWeightKg,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    activityLevel: activityLevel ?? this.activityLevel,
    goalType: goalType ?? this.goalType,
    weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
    targetCalories: targetCalories ?? this.targetCalories,
    targetProteinG: targetProteinG ?? this.targetProteinG,
    targetFatG: targetFatG ?? this.targetFatG,
    targetCarbsG: targetCarbsG ?? this.targetCarbsG,
    targetWaterMl: targetWaterMl ?? this.targetWaterMl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      currentWeightKg: data.currentWeightKg.present
          ? data.currentWeightKg.value
          : this.currentWeightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      weeklyRateKg: data.weeklyRateKg.present
          ? data.weeklyRateKg.value
          : this.weeklyRateKg,
      targetCalories: data.targetCalories.present
          ? data.targetCalories.value
          : this.targetCalories,
      targetProteinG: data.targetProteinG.present
          ? data.targetProteinG.value
          : this.targetProteinG,
      targetFatG: data.targetFatG.present
          ? data.targetFatG.value
          : this.targetFatG,
      targetCarbsG: data.targetCarbsG.present
          ? data.targetCarbsG.value
          : this.targetCarbsG,
      targetWaterMl: data.targetWaterMl.present
          ? data.targetWaterMl.value
          : this.targetWaterMl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType, ')
          ..write('weeklyRateKg: $weeklyRateKg, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('targetProteinG: $targetProteinG, ')
          ..write('targetFatG: $targetFatG, ')
          ..write('targetCarbsG: $targetCarbsG, ')
          ..write('targetWaterMl: $targetWaterMl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthDate,
    gender,
    heightCm,
    currentWeightKg,
    targetWeightKg,
    activityLevel,
    goalType,
    weeklyRateKg,
    targetCalories,
    targetProteinG,
    targetFatG,
    targetCarbsG,
    targetWaterMl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.currentWeightKg == this.currentWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.activityLevel == this.activityLevel &&
          other.goalType == this.goalType &&
          other.weeklyRateKg == this.weeklyRateKg &&
          other.targetCalories == this.targetCalories &&
          other.targetProteinG == this.targetProteinG &&
          other.targetFatG == this.targetFatG &&
          other.targetCarbsG == this.targetCarbsG &&
          other.targetWaterMl == this.targetWaterMl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<String> gender;
  final Value<double> heightCm;
  final Value<double> currentWeightKg;
  final Value<double> targetWeightKg;
  final Value<String> activityLevel;
  final Value<String> goalType;
  final Value<double> weeklyRateKg;
  final Value<int> targetCalories;
  final Value<double> targetProteinG;
  final Value<double> targetFatG;
  final Value<double> targetCarbsG;
  final Value<int> targetWaterMl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goalType = const Value.absent(),
    this.weeklyRateKg = const Value.absent(),
    this.targetCalories = const Value.absent(),
    this.targetProteinG = const Value.absent(),
    this.targetFatG = const Value.absent(),
    this.targetCarbsG = const Value.absent(),
    this.targetWaterMl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime birthDate,
    required String gender,
    required double heightCm,
    required double currentWeightKg,
    required double targetWeightKg,
    required String activityLevel,
    required String goalType,
    this.weeklyRateKg = const Value.absent(),
    required int targetCalories,
    required double targetProteinG,
    required double targetFatG,
    required double targetCarbsG,
    required int targetWaterMl,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       birthDate = Value(birthDate),
       gender = Value(gender),
       heightCm = Value(heightCm),
       currentWeightKg = Value(currentWeightKg),
       targetWeightKg = Value(targetWeightKg),
       activityLevel = Value(activityLevel),
       goalType = Value(goalType),
       targetCalories = Value(targetCalories),
       targetProteinG = Value(targetProteinG),
       targetFatG = Value(targetFatG),
       targetCarbsG = Value(targetCarbsG),
       targetWaterMl = Value(targetWaterMl);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? currentWeightKg,
    Expression<double>? targetWeightKg,
    Expression<String>? activityLevel,
    Expression<String>? goalType,
    Expression<double>? weeklyRateKg,
    Expression<int>? targetCalories,
    Expression<double>? targetProteinG,
    Expression<double>? targetFatG,
    Expression<double>? targetCarbsG,
    Expression<int>? targetWaterMl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goalType != null) 'goal_type': goalType,
      if (weeklyRateKg != null) 'weekly_rate_kg': weeklyRateKg,
      if (targetCalories != null) 'target_calories': targetCalories,
      if (targetProteinG != null) 'target_protein_g': targetProteinG,
      if (targetFatG != null) 'target_fat_g': targetFatG,
      if (targetCarbsG != null) 'target_carbs_g': targetCarbsG,
      if (targetWaterMl != null) 'target_water_ml': targetWaterMl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? birthDate,
    Value<String>? gender,
    Value<double>? heightCm,
    Value<double>? currentWeightKg,
    Value<double>? targetWeightKg,
    Value<String>? activityLevel,
    Value<String>? goalType,
    Value<double>? weeklyRateKg,
    Value<int>? targetCalories,
    Value<double>? targetProteinG,
    Value<double>? targetFatG,
    Value<double>? targetCarbsG,
    Value<int>? targetWaterMl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetFatG: targetFatG ?? this.targetFatG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (currentWeightKg.present) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (weeklyRateKg.present) {
      map['weekly_rate_kg'] = Variable<double>(weeklyRateKg.value);
    }
    if (targetCalories.present) {
      map['target_calories'] = Variable<int>(targetCalories.value);
    }
    if (targetProteinG.present) {
      map['target_protein_g'] = Variable<double>(targetProteinG.value);
    }
    if (targetFatG.present) {
      map['target_fat_g'] = Variable<double>(targetFatG.value);
    }
    if (targetCarbsG.present) {
      map['target_carbs_g'] = Variable<double>(targetCarbsG.value);
    }
    if (targetWaterMl.present) {
      map['target_water_ml'] = Variable<int>(targetWaterMl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType, ')
          ..write('weeklyRateKg: $weeklyRateKg, ')
          ..write('targetCalories: $targetCalories, ')
          ..write('targetProteinG: $targetProteinG, ')
          ..write('targetFatG: $targetFatG, ')
          ..write('targetCarbsG: $targetCarbsG, ')
          ..write('targetWaterMl: $targetWaterMl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FoodProductsTable extends FoodProducts
    with TableInfo<$FoodProductsTable, FoodProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesPer100gMeta = const VerificationMeta(
    'caloriesPer100g',
  );
  @override
  late final GeneratedColumn<double> caloriesPer100g = GeneratedColumn<double>(
    'calories_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta(
    'proteinPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta(
    'fatPer100g',
  );
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberPer100gMeta = const VerificationMeta(
    'fiberPer100g',
  );
  @override
  late final GeneratedColumn<double> fiberPer100g = GeneratedColumn<double>(
    'fiber_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('verified'),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _servingSizeGMeta = const VerificationMeta(
    'servingSizeG',
  );
  @override
  late final GeneratedColumn<double> servingSizeG = GeneratedColumn<double>(
    'serving_size_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    caloriesPer100g,
    proteinPer100g,
    fatPer100g,
    carbsPer100g,
    fiberPer100g,
    category,
    sourceType,
    barcode,
    isFavorite,
    servingSizeG,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('calories_per100g')) {
      context.handle(
        _caloriesPer100gMeta,
        caloriesPer100g.isAcceptableOrUnknown(
          data['calories_per100g']!,
          _caloriesPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesPer100gMeta);
    }
    if (data.containsKey('protein_per100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(
          data['protein_per100g']!,
          _proteinPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('fat_per100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per100g']!, _fatPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per100g']!,
          _carbsPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('fiber_per100g')) {
      context.handle(
        _fiberPer100gMeta,
        fiberPer100g.isAcceptableOrUnknown(
          data['fiber_per100g']!,
          _fiberPer100gMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('serving_size_g')) {
      context.handle(
        _servingSizeGMeta,
        servingSizeG.isAcceptableOrUnknown(
          data['serving_size_g']!,
          _servingSizeGMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {barcode},
  ];
  @override
  FoodProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      caloriesPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_per100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per100g'],
      )!,
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100g'],
      )!,
      fiberPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_per100g'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      servingSizeG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_size_g'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodProductsTable createAlias(String alias) {
    return $FoodProductsTable(attachedDatabase, alias);
  }
}

class FoodProduct extends DataClass implements Insertable<FoodProduct> {
  final int id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final double? fiberPer100g;
  final String category;
  final String sourceType;
  final String? barcode;
  final bool isFavorite;
  final double servingSizeG;
  final DateTime createdAt;
  const FoodProduct({
    required this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    this.fiberPer100g,
    required this.category,
    required this.sourceType,
    this.barcode,
    required this.isFavorite,
    required this.servingSizeG,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['calories_per100g'] = Variable<double>(caloriesPer100g);
    map['protein_per100g'] = Variable<double>(proteinPer100g);
    map['fat_per100g'] = Variable<double>(fatPer100g);
    map['carbs_per100g'] = Variable<double>(carbsPer100g);
    if (!nullToAbsent || fiberPer100g != null) {
      map['fiber_per100g'] = Variable<double>(fiberPer100g);
    }
    map['category'] = Variable<String>(category);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['serving_size_g'] = Variable<double>(servingSizeG);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodProductsCompanion toCompanion(bool nullToAbsent) {
    return FoodProductsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      caloriesPer100g: Value(caloriesPer100g),
      proteinPer100g: Value(proteinPer100g),
      fatPer100g: Value(fatPer100g),
      carbsPer100g: Value(carbsPer100g),
      fiberPer100g: fiberPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberPer100g),
      category: Value(category),
      sourceType: Value(sourceType),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      isFavorite: Value(isFavorite),
      servingSizeG: Value(servingSizeG),
      createdAt: Value(createdAt),
    );
  }

  factory FoodProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodProduct(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      caloriesPer100g: serializer.fromJson<double>(json['caloriesPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      fiberPer100g: serializer.fromJson<double?>(json['fiberPer100g']),
      category: serializer.fromJson<String>(json['category']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      servingSizeG: serializer.fromJson<double>(json['servingSizeG']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'caloriesPer100g': serializer.toJson<double>(caloriesPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'fiberPer100g': serializer.toJson<double?>(fiberPer100g),
      'category': serializer.toJson<String>(category),
      'sourceType': serializer.toJson<String>(sourceType),
      'barcode': serializer.toJson<String?>(barcode),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'servingSizeG': serializer.toJson<double>(servingSizeG),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodProduct copyWith({
    int? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    double? caloriesPer100g,
    double? proteinPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    Value<double?> fiberPer100g = const Value.absent(),
    String? category,
    String? sourceType,
    Value<String?> barcode = const Value.absent(),
    bool? isFavorite,
    double? servingSizeG,
    DateTime? createdAt,
  }) => FoodProduct(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    fiberPer100g: fiberPer100g.present ? fiberPer100g.value : this.fiberPer100g,
    category: category ?? this.category,
    sourceType: sourceType ?? this.sourceType,
    barcode: barcode.present ? barcode.value : this.barcode,
    isFavorite: isFavorite ?? this.isFavorite,
    servingSizeG: servingSizeG ?? this.servingSizeG,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodProduct copyWithCompanion(FoodProductsCompanion data) {
    return FoodProduct(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      caloriesPer100g: data.caloriesPer100g.present
          ? data.caloriesPer100g.value
          : this.caloriesPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      fatPer100g: data.fatPer100g.present
          ? data.fatPer100g.value
          : this.fatPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      fiberPer100g: data.fiberPer100g.present
          ? data.fiberPer100g.value
          : this.fiberPer100g,
      category: data.category.present ? data.category.value : this.category,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      servingSizeG: data.servingSizeG.present
          ? data.servingSizeG.value
          : this.servingSizeG,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodProduct(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('category: $category, ')
          ..write('sourceType: $sourceType, ')
          ..write('barcode: $barcode, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('servingSizeG: $servingSizeG, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    caloriesPer100g,
    proteinPer100g,
    fatPer100g,
    carbsPer100g,
    fiberPer100g,
    category,
    sourceType,
    barcode,
    isFavorite,
    servingSizeG,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodProduct &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.caloriesPer100g == this.caloriesPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.fiberPer100g == this.fiberPer100g &&
          other.category == this.category &&
          other.sourceType == this.sourceType &&
          other.barcode == this.barcode &&
          other.isFavorite == this.isFavorite &&
          other.servingSizeG == this.servingSizeG &&
          other.createdAt == this.createdAt);
}

class FoodProductsCompanion extends UpdateCompanion<FoodProduct> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<double> caloriesPer100g;
  final Value<double> proteinPer100g;
  final Value<double> fatPer100g;
  final Value<double> carbsPer100g;
  final Value<double?> fiberPer100g;
  final Value<String> category;
  final Value<String> sourceType;
  final Value<String?> barcode;
  final Value<bool> isFavorite;
  final Value<double> servingSizeG;
  final Value<DateTime> createdAt;
  const FoodProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.caloriesPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fiberPer100g = const Value.absent(),
    this.category = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.servingSizeG = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required double caloriesPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    this.fiberPer100g = const Value.absent(),
    this.category = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.servingSizeG = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       caloriesPer100g = Value(caloriesPer100g),
       proteinPer100g = Value(proteinPer100g),
       fatPer100g = Value(fatPer100g),
       carbsPer100g = Value(carbsPer100g);
  static Insertable<FoodProduct> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? caloriesPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? fiberPer100g,
    Expression<String>? category,
    Expression<String>? sourceType,
    Expression<String>? barcode,
    Expression<bool>? isFavorite,
    Expression<double>? servingSizeG,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (caloriesPer100g != null) 'calories_per100g': caloriesPer100g,
      if (proteinPer100g != null) 'protein_per100g': proteinPer100g,
      if (fatPer100g != null) 'fat_per100g': fatPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (fiberPer100g != null) 'fiber_per100g': fiberPer100g,
      if (category != null) 'category': category,
      if (sourceType != null) 'source_type': sourceType,
      if (barcode != null) 'barcode': barcode,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (servingSizeG != null) 'serving_size_g': servingSizeG,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<double>? caloriesPer100g,
    Value<double>? proteinPer100g,
    Value<double>? fatPer100g,
    Value<double>? carbsPer100g,
    Value<double?>? fiberPer100g,
    Value<String>? category,
    Value<String>? sourceType,
    Value<String?>? barcode,
    Value<bool>? isFavorite,
    Value<double>? servingSizeG,
    Value<DateTime>? createdAt,
  }) {
    return FoodProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      barcode: barcode ?? this.barcode,
      isFavorite: isFavorite ?? this.isFavorite,
      servingSizeG: servingSizeG ?? this.servingSizeG,
      createdAt: createdAt ?? this.createdAt,
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
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (caloriesPer100g.present) {
      map['calories_per100g'] = Variable<double>(caloriesPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per100g'] = Variable<double>(proteinPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per100g'] = Variable<double>(fatPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (fiberPer100g.present) {
      map['fiber_per100g'] = Variable<double>(fiberPer100g.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (servingSizeG.present) {
      map['serving_size_g'] = Variable<double>(servingSizeG.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('category: $category, ')
          ..write('sourceType: $sourceType, ')
          ..write('barcode: $barcode, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('servingSizeG: $servingSizeG, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodProductIdMeta = const VerificationMeta(
    'foodProductId',
  );
  @override
  late final GeneratedColumn<int> foodProductId = GeneratedColumn<int>(
    'food_product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculatedCaloriesMeta =
      const VerificationMeta('calculatedCalories');
  @override
  late final GeneratedColumn<double> calculatedCalories =
      GeneratedColumn<double>(
        'calculated_calories',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calculatedProteinMeta = const VerificationMeta(
    'calculatedProtein',
  );
  @override
  late final GeneratedColumn<double> calculatedProtein =
      GeneratedColumn<double>(
        'calculated_protein',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calculatedFatMeta = const VerificationMeta(
    'calculatedFat',
  );
  @override
  late final GeneratedColumn<double> calculatedFat = GeneratedColumn<double>(
    'calculated_fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculatedCarbsMeta = const VerificationMeta(
    'calculatedCarbs',
  );
  @override
  late final GeneratedColumn<double> calculatedCarbs = GeneratedColumn<double>(
    'calculated_carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealType,
    foodProductId,
    customName,
    grams,
    calculatedCalories,
    calculatedProtein,
    calculatedFat,
    calculatedCarbs,
    entryDate,
    timestamp,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('food_product_id')) {
      context.handle(
        _foodProductIdMeta,
        foodProductId.isAcceptableOrUnknown(
          data['food_product_id']!,
          _foodProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodProductIdMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    } else if (isInserting) {
      context.missing(_customNameMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calculated_calories')) {
      context.handle(
        _calculatedCaloriesMeta,
        calculatedCalories.isAcceptableOrUnknown(
          data['calculated_calories']!,
          _calculatedCaloriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedCaloriesMeta);
    }
    if (data.containsKey('calculated_protein')) {
      context.handle(
        _calculatedProteinMeta,
        calculatedProtein.isAcceptableOrUnknown(
          data['calculated_protein']!,
          _calculatedProteinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedProteinMeta);
    }
    if (data.containsKey('calculated_fat')) {
      context.handle(
        _calculatedFatMeta,
        calculatedFat.isAcceptableOrUnknown(
          data['calculated_fat']!,
          _calculatedFatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedFatMeta);
    }
    if (data.containsKey('calculated_carbs')) {
      context.handle(
        _calculatedCarbsMeta,
        calculatedCarbs.isAcceptableOrUnknown(
          data['calculated_carbs']!,
          _calculatedCarbsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedCarbsMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      foodProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_product_id'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      calculatedCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calculated_calories'],
      )!,
      calculatedProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calculated_protein'],
      )!,
      calculatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calculated_fat'],
      )!,
      calculatedCarbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calculated_carbs'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;
  final String mealType;
  final int foodProductId;
  final String customName;
  final double grams;
  final double calculatedCalories;
  final double calculatedProtein;
  final double calculatedFat;
  final double calculatedCarbs;
  final DateTime entryDate;
  final DateTime timestamp;
  final String? notes;
  const DiaryEntry({
    required this.id,
    required this.mealType,
    required this.foodProductId,
    required this.customName,
    required this.grams,
    required this.calculatedCalories,
    required this.calculatedProtein,
    required this.calculatedFat,
    required this.calculatedCarbs,
    required this.entryDate,
    required this.timestamp,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_type'] = Variable<String>(mealType);
    map['food_product_id'] = Variable<int>(foodProductId);
    map['custom_name'] = Variable<String>(customName);
    map['grams'] = Variable<double>(grams);
    map['calculated_calories'] = Variable<double>(calculatedCalories);
    map['calculated_protein'] = Variable<double>(calculatedProtein);
    map['calculated_fat'] = Variable<double>(calculatedFat);
    map['calculated_carbs'] = Variable<double>(calculatedCarbs);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      mealType: Value(mealType),
      foodProductId: Value(foodProductId),
      customName: Value(customName),
      grams: Value(grams),
      calculatedCalories: Value(calculatedCalories),
      calculatedProtein: Value(calculatedProtein),
      calculatedFat: Value(calculatedFat),
      calculatedCarbs: Value(calculatedCarbs),
      entryDate: Value(entryDate),
      timestamp: Value(timestamp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      mealType: serializer.fromJson<String>(json['mealType']),
      foodProductId: serializer.fromJson<int>(json['foodProductId']),
      customName: serializer.fromJson<String>(json['customName']),
      grams: serializer.fromJson<double>(json['grams']),
      calculatedCalories: serializer.fromJson<double>(
        json['calculatedCalories'],
      ),
      calculatedProtein: serializer.fromJson<double>(json['calculatedProtein']),
      calculatedFat: serializer.fromJson<double>(json['calculatedFat']),
      calculatedCarbs: serializer.fromJson<double>(json['calculatedCarbs']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealType': serializer.toJson<String>(mealType),
      'foodProductId': serializer.toJson<int>(foodProductId),
      'customName': serializer.toJson<String>(customName),
      'grams': serializer.toJson<double>(grams),
      'calculatedCalories': serializer.toJson<double>(calculatedCalories),
      'calculatedProtein': serializer.toJson<double>(calculatedProtein),
      'calculatedFat': serializer.toJson<double>(calculatedFat),
      'calculatedCarbs': serializer.toJson<double>(calculatedCarbs),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DiaryEntry copyWith({
    int? id,
    String? mealType,
    int? foodProductId,
    String? customName,
    double? grams,
    double? calculatedCalories,
    double? calculatedProtein,
    double? calculatedFat,
    double? calculatedCarbs,
    DateTime? entryDate,
    DateTime? timestamp,
    Value<String?> notes = const Value.absent(),
  }) => DiaryEntry(
    id: id ?? this.id,
    mealType: mealType ?? this.mealType,
    foodProductId: foodProductId ?? this.foodProductId,
    customName: customName ?? this.customName,
    grams: grams ?? this.grams,
    calculatedCalories: calculatedCalories ?? this.calculatedCalories,
    calculatedProtein: calculatedProtein ?? this.calculatedProtein,
    calculatedFat: calculatedFat ?? this.calculatedFat,
    calculatedCarbs: calculatedCarbs ?? this.calculatedCarbs,
    entryDate: entryDate ?? this.entryDate,
    timestamp: timestamp ?? this.timestamp,
    notes: notes.present ? notes.value : this.notes,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodProductId: data.foodProductId.present
          ? data.foodProductId.value
          : this.foodProductId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      grams: data.grams.present ? data.grams.value : this.grams,
      calculatedCalories: data.calculatedCalories.present
          ? data.calculatedCalories.value
          : this.calculatedCalories,
      calculatedProtein: data.calculatedProtein.present
          ? data.calculatedProtein.value
          : this.calculatedProtein,
      calculatedFat: data.calculatedFat.present
          ? data.calculatedFat.value
          : this.calculatedFat,
      calculatedCarbs: data.calculatedCarbs.present
          ? data.calculatedCarbs.value
          : this.calculatedCarbs,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('mealType: $mealType, ')
          ..write('foodProductId: $foodProductId, ')
          ..write('customName: $customName, ')
          ..write('grams: $grams, ')
          ..write('calculatedCalories: $calculatedCalories, ')
          ..write('calculatedProtein: $calculatedProtein, ')
          ..write('calculatedFat: $calculatedFat, ')
          ..write('calculatedCarbs: $calculatedCarbs, ')
          ..write('entryDate: $entryDate, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealType,
    foodProductId,
    customName,
    grams,
    calculatedCalories,
    calculatedProtein,
    calculatedFat,
    calculatedCarbs,
    entryDate,
    timestamp,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.mealType == this.mealType &&
          other.foodProductId == this.foodProductId &&
          other.customName == this.customName &&
          other.grams == this.grams &&
          other.calculatedCalories == this.calculatedCalories &&
          other.calculatedProtein == this.calculatedProtein &&
          other.calculatedFat == this.calculatedFat &&
          other.calculatedCarbs == this.calculatedCarbs &&
          other.entryDate == this.entryDate &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<String> mealType;
  final Value<int> foodProductId;
  final Value<String> customName;
  final Value<double> grams;
  final Value<double> calculatedCalories;
  final Value<double> calculatedProtein;
  final Value<double> calculatedFat;
  final Value<double> calculatedCarbs;
  final Value<DateTime> entryDate;
  final Value<DateTime> timestamp;
  final Value<String?> notes;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodProductId = const Value.absent(),
    this.customName = const Value.absent(),
    this.grams = const Value.absent(),
    this.calculatedCalories = const Value.absent(),
    this.calculatedProtein = const Value.absent(),
    this.calculatedFat = const Value.absent(),
    this.calculatedCarbs = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String mealType,
    required int foodProductId,
    required String customName,
    required double grams,
    required double calculatedCalories,
    required double calculatedProtein,
    required double calculatedFat,
    required double calculatedCarbs,
    required DateTime entryDate,
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
  }) : mealType = Value(mealType),
       foodProductId = Value(foodProductId),
       customName = Value(customName),
       grams = Value(grams),
       calculatedCalories = Value(calculatedCalories),
       calculatedProtein = Value(calculatedProtein),
       calculatedFat = Value(calculatedFat),
       calculatedCarbs = Value(calculatedCarbs),
       entryDate = Value(entryDate);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<String>? mealType,
    Expression<int>? foodProductId,
    Expression<String>? customName,
    Expression<double>? grams,
    Expression<double>? calculatedCalories,
    Expression<double>? calculatedProtein,
    Expression<double>? calculatedFat,
    Expression<double>? calculatedCarbs,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? timestamp,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealType != null) 'meal_type': mealType,
      if (foodProductId != null) 'food_product_id': foodProductId,
      if (customName != null) 'custom_name': customName,
      if (grams != null) 'grams': grams,
      if (calculatedCalories != null) 'calculated_calories': calculatedCalories,
      if (calculatedProtein != null) 'calculated_protein': calculatedProtein,
      if (calculatedFat != null) 'calculated_fat': calculatedFat,
      if (calculatedCarbs != null) 'calculated_carbs': calculatedCarbs,
      if (entryDate != null) 'entry_date': entryDate,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? mealType,
    Value<int>? foodProductId,
    Value<String>? customName,
    Value<double>? grams,
    Value<double>? calculatedCalories,
    Value<double>? calculatedProtein,
    Value<double>? calculatedFat,
    Value<double>? calculatedCarbs,
    Value<DateTime>? entryDate,
    Value<DateTime>? timestamp,
    Value<String?>? notes,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      foodProductId: foodProductId ?? this.foodProductId,
      customName: customName ?? this.customName,
      grams: grams ?? this.grams,
      calculatedCalories: calculatedCalories ?? this.calculatedCalories,
      calculatedProtein: calculatedProtein ?? this.calculatedProtein,
      calculatedFat: calculatedFat ?? this.calculatedFat,
      calculatedCarbs: calculatedCarbs ?? this.calculatedCarbs,
      entryDate: entryDate ?? this.entryDate,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (foodProductId.present) {
      map['food_product_id'] = Variable<int>(foodProductId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (calculatedCalories.present) {
      map['calculated_calories'] = Variable<double>(calculatedCalories.value);
    }
    if (calculatedProtein.present) {
      map['calculated_protein'] = Variable<double>(calculatedProtein.value);
    }
    if (calculatedFat.present) {
      map['calculated_fat'] = Variable<double>(calculatedFat.value);
    }
    if (calculatedCarbs.present) {
      map['calculated_carbs'] = Variable<double>(calculatedCarbs.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mealType: $mealType, ')
          ..write('foodProductId: $foodProductId, ')
          ..write('customName: $customName, ')
          ..write('grams: $grams, ')
          ..write('calculatedCalories: $calculatedCalories, ')
          ..write('calculatedProtein: $calculatedProtein, ')
          ..write('calculatedFat: $calculatedFat, ')
          ..write('calculatedCarbs: $calculatedCarbs, ')
          ..write('entryDate: $entryDate, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WaterEntriesTable extends WaterEntries
    with TableInfo<$WaterEntriesTable, WaterEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMlMeta = const VerificationMeta(
    'amountMl',
  );
  @override
  late final GeneratedColumn<int> amountMl = GeneratedColumn<int>(
    'amount_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amountMl, entryDate, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_ml')) {
      context.handle(
        _amountMlMeta,
        amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_ml'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $WaterEntriesTable createAlias(String alias) {
    return $WaterEntriesTable(attachedDatabase, alias);
  }
}

class WaterEntry extends DataClass implements Insertable<WaterEntry> {
  final int id;
  final int amountMl;
  final DateTime entryDate;
  final DateTime timestamp;
  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.entryDate,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_ml'] = Variable<int>(amountMl);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WaterEntriesCompanion toCompanion(bool nullToAbsent) {
    return WaterEntriesCompanion(
      id: Value(id),
      amountMl: Value(amountMl),
      entryDate: Value(entryDate),
      timestamp: Value(timestamp),
    );
  }

  factory WaterEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterEntry(
      id: serializer.fromJson<int>(json['id']),
      amountMl: serializer.fromJson<int>(json['amountMl']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountMl': serializer.toJson<int>(amountMl),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WaterEntry copyWith({
    int? id,
    int? amountMl,
    DateTime? entryDate,
    DateTime? timestamp,
  }) => WaterEntry(
    id: id ?? this.id,
    amountMl: amountMl ?? this.amountMl,
    entryDate: entryDate ?? this.entryDate,
    timestamp: timestamp ?? this.timestamp,
  );
  WaterEntry copyWithCompanion(WaterEntriesCompanion data) {
    return WaterEntry(
      id: data.id.present ? data.id.value : this.id,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterEntry(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('entryDate: $entryDate, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amountMl, entryDate, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterEntry &&
          other.id == this.id &&
          other.amountMl == this.amountMl &&
          other.entryDate == this.entryDate &&
          other.timestamp == this.timestamp);
}

class WaterEntriesCompanion extends UpdateCompanion<WaterEntry> {
  final Value<int> id;
  final Value<int> amountMl;
  final Value<DateTime> entryDate;
  final Value<DateTime> timestamp;
  const WaterEntriesCompanion({
    this.id = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WaterEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int amountMl,
    required DateTime entryDate,
    this.timestamp = const Value.absent(),
  }) : amountMl = Value(amountMl),
       entryDate = Value(entryDate);
  static Insertable<WaterEntry> custom({
    Expression<int>? id,
    Expression<int>? amountMl,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMl != null) 'amount_ml': amountMl,
      if (entryDate != null) 'entry_date': entryDate,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WaterEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountMl,
    Value<DateTime>? entryDate,
    Value<DateTime>? timestamp,
  }) {
    return WaterEntriesCompanion(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      entryDate: entryDate ?? this.entryDate,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<int>(amountMl.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('entryDate: $entryDate, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weightKg,
    entryDate,
    notes,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntry extends DataClass implements Insertable<WeightEntry> {
  final int id;
  final double weightKg;
  final DateTime entryDate;
  final String? notes;
  final DateTime timestamp;
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.entryDate,
    this.notes,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight_kg'] = Variable<double>(weightKg);
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      weightKg: Value(weightKg),
      entryDate: Value(entryDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      timestamp: Value(timestamp),
    );
  }

  factory WeightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntry(
      id: serializer.fromJson<int>(json['id']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightKg': serializer.toJson<double>(weightKg),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'notes': serializer.toJson<String?>(notes),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WeightEntry copyWith({
    int? id,
    double? weightKg,
    DateTime? entryDate,
    Value<String?> notes = const Value.absent(),
    DateTime? timestamp,
  }) => WeightEntry(
    id: id ?? this.id,
    weightKg: weightKg ?? this.weightKg,
    entryDate: entryDate ?? this.entryDate,
    notes: notes.present ? notes.value : this.notes,
    timestamp: timestamp ?? this.timestamp,
  );
  WeightEntry copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntry(
      id: data.id.present ? data.id.value : this.id,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntry(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('entryDate: $entryDate, ')
          ..write('notes: $notes, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weightKg, entryDate, notes, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntry &&
          other.id == this.id &&
          other.weightKg == this.weightKg &&
          other.entryDate == this.entryDate &&
          other.notes == this.notes &&
          other.timestamp == this.timestamp);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntry> {
  final Value<int> id;
  final Value<double> weightKg;
  final Value<DateTime> entryDate;
  final Value<String?> notes;
  final Value<DateTime> timestamp;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required double weightKg,
    required DateTime entryDate,
    this.notes = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : weightKg = Value(weightKg),
       entryDate = Value(entryDate);
  static Insertable<WeightEntry> custom({
    Expression<int>? id,
    Expression<double>? weightKg,
    Expression<DateTime>? entryDate,
    Expression<String>? notes,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightKg != null) 'weight_kg': weightKg,
      if (entryDate != null) 'entry_date': entryDate,
      if (notes != null) 'notes': notes,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<int>? id,
    Value<double>? weightKg,
    Value<DateTime>? entryDate,
    Value<String?>? notes,
    Value<DateTime>? timestamp,
  }) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      entryDate: entryDate ?? this.entryDate,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('entryDate: $entryDate, ')
          ..write('notes: $notes, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prepTimeMinutesMeta = const VerificationMeta(
    'prepTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> prepTimeMinutes = GeneratedColumn<int>(
    'prep_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    prepTimeMinutes,
    servings,
    category,
    isFavorite,
    imageUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('prep_time_minutes')) {
      context.handle(
        _prepTimeMinutesMeta,
        prepTimeMinutes.isAcceptableOrUnknown(
          data['prep_time_minutes']!,
          _prepTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      prepTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time_minutes'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String name;
  final String? description;
  final int prepTimeMinutes;
  final int servings;
  final String category;
  final bool isFavorite;
  final String? imageUrl;
  final DateTime createdAt;
  const Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.prepTimeMinutes,
    required this.servings,
    required this.category,
    required this.isFavorite,
    this.imageUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['prep_time_minutes'] = Variable<int>(prepTimeMinutes);
    map['servings'] = Variable<int>(servings);
    map['category'] = Variable<String>(category);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      prepTimeMinutes: Value(prepTimeMinutes),
      servings: Value(servings),
      category: Value(category),
      isFavorite: Value(isFavorite),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      createdAt: Value(createdAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      prepTimeMinutes: serializer.fromJson<int>(json['prepTimeMinutes']),
      servings: serializer.fromJson<int>(json['servings']),
      category: serializer.fromJson<String>(json['category']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'prepTimeMinutes': serializer.toJson<int>(prepTimeMinutes),
      'servings': serializer.toJson<int>(servings),
      'category': serializer.toJson<String>(category),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recipe copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? prepTimeMinutes,
    int? servings,
    String? category,
    bool? isFavorite,
    Value<String?> imageUrl = const Value.absent(),
    DateTime? createdAt,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
    servings: servings ?? this.servings,
    category: category ?? this.category,
    isFavorite: isFavorite ?? this.isFavorite,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      prepTimeMinutes: data.prepTimeMinutes.present
          ? data.prepTimeMinutes.value
          : this.prepTimeMinutes,
      servings: data.servings.present ? data.servings.value : this.servings,
      category: data.category.present ? data.category.value : this.category,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('servings: $servings, ')
          ..write('category: $category, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    prepTimeMinutes,
    servings,
    category,
    isFavorite,
    imageUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.prepTimeMinutes == this.prepTimeMinutes &&
          other.servings == this.servings &&
          other.category == this.category &&
          other.isFavorite == this.isFavorite &&
          other.imageUrl == this.imageUrl &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> prepTimeMinutes;
  final Value<int> servings;
  final Value<String> category;
  final Value<bool> isFavorite;
  final Value<String?> imageUrl;
  final Value<DateTime> createdAt;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.servings = const Value.absent(),
    this.category = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.servings = const Value.absent(),
    this.category = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? prepTimeMinutes,
    Expression<int>? servings,
    Expression<String>? category,
    Expression<bool>? isFavorite,
    Expression<String>? imageUrl,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (prepTimeMinutes != null) 'prep_time_minutes': prepTimeMinutes,
      if (servings != null) 'servings': servings,
      if (category != null) 'category': category,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? prepTimeMinutes,
    Value<int>? servings,
    Value<String>? category,
    Value<bool>? isFavorite,
    Value<String?>? imageUrl,
    Value<DateTime>? createdAt,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (prepTimeMinutes.present) {
      map['prep_time_minutes'] = Variable<int>(prepTimeMinutes.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('servings: $servings, ')
          ..write('category: $category, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodProductIdMeta = const VerificationMeta(
    'foodProductId',
  );
  @override
  late final GeneratedColumn<int> foodProductId = GeneratedColumn<int>(
    'food_product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    foodProductId,
    grams,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('food_product_id')) {
      context.handle(
        _foodProductIdMeta,
        foodProductId.isAcceptableOrUnknown(
          data['food_product_id']!,
          _foodProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodProductIdMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      foodProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_product_id'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final int recipeId;
  final int foodProductId;
  final double grams;
  final String? notes;
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.foodProductId,
    required this.grams,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['food_product_id'] = Variable<int>(foodProductId);
    map['grams'] = Variable<double>(grams);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      foodProductId: Value(foodProductId),
      grams: Value(grams),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      foodProductId: serializer.fromJson<int>(json['foodProductId']),
      grams: serializer.fromJson<double>(json['grams']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'foodProductId': serializer.toJson<int>(foodProductId),
      'grams': serializer.toJson<double>(grams),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    int? recipeId,
    int? foodProductId,
    double? grams,
    Value<String?> notes = const Value.absent(),
  }) => RecipeIngredient(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    foodProductId: foodProductId ?? this.foodProductId,
    grams: grams ?? this.grams,
    notes: notes.present ? notes.value : this.notes,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      foodProductId: data.foodProductId.present
          ? data.foodProductId.value
          : this.foodProductId,
      grams: data.grams.present ? data.grams.value : this.grams,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodProductId: $foodProductId, ')
          ..write('grams: $grams, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, foodProductId, grams, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.foodProductId == this.foodProductId &&
          other.grams == this.grams &&
          other.notes == this.notes);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> foodProductId;
  final Value<double> grams;
  final Value<String?> notes;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.foodProductId = const Value.absent(),
    this.grams = const Value.absent(),
    this.notes = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int foodProductId,
    required double grams,
    this.notes = const Value.absent(),
  }) : recipeId = Value(recipeId),
       foodProductId = Value(foodProductId),
       grams = Value(grams);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? foodProductId,
    Expression<double>? grams,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (foodProductId != null) 'food_product_id': foodProductId,
      if (grams != null) 'grams': grams,
      if (notes != null) 'notes': notes,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int>? foodProductId,
    Value<double>? grams,
    Value<String?>? notes,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodProductId: foodProductId ?? this.foodProductId,
      grams: grams ?? this.grams,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (foodProductId.present) {
      map['food_product_id'] = Variable<int>(foodProductId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodProductId: $foodProductId, ')
          ..write('grams: $grams, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $MealPlansTable extends MealPlans
    with TableInfo<$MealPlansTable, MealPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> weekStartDate =
      GeneratedColumn<DateTime>(
        'week_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, weekStartDate, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MealPlansTable createAlias(String alias) {
    return $MealPlansTable(attachedDatabase, alias);
  }
}

class MealPlan extends DataClass implements Insertable<MealPlan> {
  final int id;
  final DateTime weekStartDate;
  final String? notes;
  final DateTime createdAt;
  const MealPlan({
    required this.id,
    required this.weekStartDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealPlansCompanion toCompanion(bool nullToAbsent) {
    return MealPlansCompanion(
      id: Value(id),
      weekStartDate: Value(weekStartDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MealPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlan(
      id: serializer.fromJson<int>(json['id']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MealPlan copyWith({
    int? id,
    DateTime? weekStartDate,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MealPlan(
    id: id ?? this.id,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MealPlan copyWithCompanion(MealPlansCompanion data) {
    return MealPlan(
      id: data.id.present ? data.id.value : this.id,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlan(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weekStartDate, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlan &&
          other.id == this.id &&
          other.weekStartDate == this.weekStartDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MealPlansCompanion extends UpdateCompanion<MealPlan> {
  final Value<int> id;
  final Value<DateTime> weekStartDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MealPlansCompanion({
    this.id = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MealPlansCompanion.insert({
    this.id = const Value.absent(),
    required DateTime weekStartDate,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : weekStartDate = Value(weekStartDate);
  static Insertable<MealPlan> custom({
    Expression<int>? id,
    Expression<DateTime>? weekStartDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MealPlansCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? weekStartDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MealPlansCompanion(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<DateTime>(weekStartDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlansCompanion(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MealPlanItemsTable extends MealPlanItems
    with TableInfo<$MealPlanItemsTable, MealPlanItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mealPlanIdMeta = const VerificationMeta(
    'mealPlanId',
  );
  @override
  late final GeneratedColumn<int> mealPlanId = GeneratedColumn<int>(
    'meal_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDateMeta = const VerificationMeta(
    'plannedDate',
  );
  @override
  late final GeneratedColumn<DateTime> plannedDate = GeneratedColumn<DateTime>(
    'planned_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNoteMeta = const VerificationMeta(
    'customNote',
  );
  @override
  late final GeneratedColumn<String> customNote = GeneratedColumn<String>(
    'custom_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealPlanId,
    recipeId,
    plannedDate,
    mealType,
    customNote,
    servings,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealPlanItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_plan_id')) {
      context.handle(
        _mealPlanIdMeta,
        mealPlanId.isAcceptableOrUnknown(
          data['meal_plan_id']!,
          _mealPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealPlanIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('planned_date')) {
      context.handle(
        _plannedDateMeta,
        plannedDate.isAcceptableOrUnknown(
          data['planned_date']!,
          _plannedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDateMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('custom_note')) {
      context.handle(
        _customNoteMeta,
        customNote.isAcceptableOrUnknown(data['custom_note']!, _customNoteMeta),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlanItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlanItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_plan_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      ),
      plannedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_date'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      customNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_note'],
      ),
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings'],
      )!,
    );
  }

  @override
  $MealPlanItemsTable createAlias(String alias) {
    return $MealPlanItemsTable(attachedDatabase, alias);
  }
}

class MealPlanItem extends DataClass implements Insertable<MealPlanItem> {
  final int id;
  final int mealPlanId;
  final int? recipeId;
  final DateTime plannedDate;
  final String mealType;
  final String? customNote;
  final double servings;
  const MealPlanItem({
    required this.id,
    required this.mealPlanId,
    this.recipeId,
    required this.plannedDate,
    required this.mealType,
    this.customNote,
    required this.servings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_plan_id'] = Variable<int>(mealPlanId);
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<int>(recipeId);
    }
    map['planned_date'] = Variable<DateTime>(plannedDate);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || customNote != null) {
      map['custom_note'] = Variable<String>(customNote);
    }
    map['servings'] = Variable<double>(servings);
    return map;
  }

  MealPlanItemsCompanion toCompanion(bool nullToAbsent) {
    return MealPlanItemsCompanion(
      id: Value(id),
      mealPlanId: Value(mealPlanId),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      plannedDate: Value(plannedDate),
      mealType: Value(mealType),
      customNote: customNote == null && nullToAbsent
          ? const Value.absent()
          : Value(customNote),
      servings: Value(servings),
    );
  }

  factory MealPlanItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlanItem(
      id: serializer.fromJson<int>(json['id']),
      mealPlanId: serializer.fromJson<int>(json['mealPlanId']),
      recipeId: serializer.fromJson<int?>(json['recipeId']),
      plannedDate: serializer.fromJson<DateTime>(json['plannedDate']),
      mealType: serializer.fromJson<String>(json['mealType']),
      customNote: serializer.fromJson<String?>(json['customNote']),
      servings: serializer.fromJson<double>(json['servings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealPlanId': serializer.toJson<int>(mealPlanId),
      'recipeId': serializer.toJson<int?>(recipeId),
      'plannedDate': serializer.toJson<DateTime>(plannedDate),
      'mealType': serializer.toJson<String>(mealType),
      'customNote': serializer.toJson<String?>(customNote),
      'servings': serializer.toJson<double>(servings),
    };
  }

  MealPlanItem copyWith({
    int? id,
    int? mealPlanId,
    Value<int?> recipeId = const Value.absent(),
    DateTime? plannedDate,
    String? mealType,
    Value<String?> customNote = const Value.absent(),
    double? servings,
  }) => MealPlanItem(
    id: id ?? this.id,
    mealPlanId: mealPlanId ?? this.mealPlanId,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    plannedDate: plannedDate ?? this.plannedDate,
    mealType: mealType ?? this.mealType,
    customNote: customNote.present ? customNote.value : this.customNote,
    servings: servings ?? this.servings,
  );
  MealPlanItem copyWithCompanion(MealPlanItemsCompanion data) {
    return MealPlanItem(
      id: data.id.present ? data.id.value : this.id,
      mealPlanId: data.mealPlanId.present
          ? data.mealPlanId.value
          : this.mealPlanId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      plannedDate: data.plannedDate.present
          ? data.plannedDate.value
          : this.plannedDate,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      customNote: data.customNote.present
          ? data.customNote.value
          : this.customNote,
      servings: data.servings.present ? data.servings.value : this.servings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanItem(')
          ..write('id: $id, ')
          ..write('mealPlanId: $mealPlanId, ')
          ..write('recipeId: $recipeId, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('mealType: $mealType, ')
          ..write('customNote: $customNote, ')
          ..write('servings: $servings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealPlanId,
    recipeId,
    plannedDate,
    mealType,
    customNote,
    servings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlanItem &&
          other.id == this.id &&
          other.mealPlanId == this.mealPlanId &&
          other.recipeId == this.recipeId &&
          other.plannedDate == this.plannedDate &&
          other.mealType == this.mealType &&
          other.customNote == this.customNote &&
          other.servings == this.servings);
}

class MealPlanItemsCompanion extends UpdateCompanion<MealPlanItem> {
  final Value<int> id;
  final Value<int> mealPlanId;
  final Value<int?> recipeId;
  final Value<DateTime> plannedDate;
  final Value<String> mealType;
  final Value<String?> customNote;
  final Value<double> servings;
  const MealPlanItemsCompanion({
    this.id = const Value.absent(),
    this.mealPlanId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.plannedDate = const Value.absent(),
    this.mealType = const Value.absent(),
    this.customNote = const Value.absent(),
    this.servings = const Value.absent(),
  });
  MealPlanItemsCompanion.insert({
    this.id = const Value.absent(),
    required int mealPlanId,
    this.recipeId = const Value.absent(),
    required DateTime plannedDate,
    required String mealType,
    this.customNote = const Value.absent(),
    this.servings = const Value.absent(),
  }) : mealPlanId = Value(mealPlanId),
       plannedDate = Value(plannedDate),
       mealType = Value(mealType);
  static Insertable<MealPlanItem> custom({
    Expression<int>? id,
    Expression<int>? mealPlanId,
    Expression<int>? recipeId,
    Expression<DateTime>? plannedDate,
    Expression<String>? mealType,
    Expression<String>? customNote,
    Expression<double>? servings,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealPlanId != null) 'meal_plan_id': mealPlanId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (plannedDate != null) 'planned_date': plannedDate,
      if (mealType != null) 'meal_type': mealType,
      if (customNote != null) 'custom_note': customNote,
      if (servings != null) 'servings': servings,
    });
  }

  MealPlanItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? mealPlanId,
    Value<int?>? recipeId,
    Value<DateTime>? plannedDate,
    Value<String>? mealType,
    Value<String?>? customNote,
    Value<double>? servings,
  }) {
    return MealPlanItemsCompanion(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      recipeId: recipeId ?? this.recipeId,
      plannedDate: plannedDate ?? this.plannedDate,
      mealType: mealType ?? this.mealType,
      customNote: customNote ?? this.customNote,
      servings: servings ?? this.servings,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealPlanId.present) {
      map['meal_plan_id'] = Variable<int>(mealPlanId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (plannedDate.present) {
      map['planned_date'] = Variable<DateTime>(plannedDate.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (customNote.present) {
      map['custom_note'] = Variable<String>(customNote.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealPlanId: $mealPlanId, ')
          ..write('recipeId: $recipeId, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('mealType: $mealType, ')
          ..write('customNote: $customNote, ')
          ..write('servings: $servings')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredCountMeta = const VerificationMeta(
    'requiredCount',
  );
  @override
  late final GeneratedColumn<int> requiredCount = GeneratedColumn<int>(
    'required_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    title,
    description,
    iconName,
    requiredCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('required_count')) {
      context.handle(
        _requiredCountMeta,
        requiredCount.isAcceptableOrUnknown(
          data['required_count']!,
          _requiredCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      requiredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required_count'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String key;
  final String title;
  final String description;
  final String iconName;
  final int requiredCount;
  const Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon_name'] = Variable<String>(iconName);
    map['required_count'] = Variable<int>(requiredCount);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      key: Value(key),
      title: Value(title),
      description: Value(description),
      iconName: Value(iconName),
      requiredCount: Value(requiredCount),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      iconName: serializer.fromJson<String>(json['iconName']),
      requiredCount: serializer.fromJson<int>(json['requiredCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'iconName': serializer.toJson<String>(iconName),
      'requiredCount': serializer.toJson<int>(requiredCount),
    };
  }

  Achievement copyWith({
    int? id,
    String? key,
    String? title,
    String? description,
    String? iconName,
    int? requiredCount,
  }) => Achievement(
    id: id ?? this.id,
    key: key ?? this.key,
    title: title ?? this.title,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    requiredCount: requiredCount ?? this.requiredCount,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      requiredCount: data.requiredCount.present
          ? data.requiredCount.value
          : this.requiredCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('requiredCount: $requiredCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, key, title, description, iconName, requiredCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.key == this.key &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconName == this.iconName &&
          other.requiredCount == this.requiredCount);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> title;
  final Value<String> description;
  final Value<String> iconName;
  final Value<int> requiredCount;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.requiredCount = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String title,
    required String description,
    required String iconName,
    this.requiredCount = const Value.absent(),
  }) : key = Value(key),
       title = Value(title),
       description = Value(description),
       iconName = Value(iconName);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconName,
    Expression<int>? requiredCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (requiredCount != null) 'required_count': requiredCount,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? title,
    Value<String>? description,
    Value<String>? iconName,
    Value<int>? requiredCount,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requiredCount: requiredCount ?? this.requiredCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (requiredCount.present) {
      map['required_count'] = Variable<int>(requiredCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('requiredCount: $requiredCount')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementsTable extends UserAchievements
    with TableInfo<$UserAchievementsTable, UserAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<int> achievementId = GeneratedColumn<int>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    achievementId,
    currentCount,
    isUnlocked,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achievement_id'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $UserAchievementsTable createAlias(String alias) {
    return $UserAchievementsTable(attachedDatabase, alias);
  }
}

class UserAchievement extends DataClass implements Insertable<UserAchievement> {
  final int id;
  final int achievementId;
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  const UserAchievement({
    required this.id,
    required this.achievementId,
    required this.currentCount,
    required this.isUnlocked,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['achievement_id'] = Variable<int>(achievementId);
    map['current_count'] = Variable<int>(currentCount);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  UserAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementsCompanion(
      id: Value(id),
      achievementId: Value(achievementId),
      currentCount: Value(currentCount),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory UserAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievement(
      id: serializer.fromJson<int>(json['id']),
      achievementId: serializer.fromJson<int>(json['achievementId']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'achievementId': serializer.toJson<int>(achievementId),
      'currentCount': serializer.toJson<int>(currentCount),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  UserAchievement copyWith({
    int? id,
    int? achievementId,
    int? currentCount,
    bool? isUnlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => UserAchievement(
    id: id ?? this.id,
    achievementId: achievementId ?? this.achievementId,
    currentCount: currentCount ?? this.currentCount,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  UserAchievement copyWithCompanion(UserAchievementsCompanion data) {
    return UserAchievement(
      id: data.id.present ? data.id.value : this.id,
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievement(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('currentCount: $currentCount, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, achievementId, currentCount, isUnlocked, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievement &&
          other.id == this.id &&
          other.achievementId == this.achievementId &&
          other.currentCount == this.currentCount &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt);
}

class UserAchievementsCompanion extends UpdateCompanion<UserAchievement> {
  final Value<int> id;
  final Value<int> achievementId;
  final Value<int> currentCount;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  const UserAchievementsCompanion({
    this.id = const Value.absent(),
    this.achievementId = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  UserAchievementsCompanion.insert({
    this.id = const Value.absent(),
    required int achievementId,
    this.currentCount = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  }) : achievementId = Value(achievementId);
  static Insertable<UserAchievement> custom({
    Expression<int>? id,
    Expression<int>? achievementId,
    Expression<int>? currentCount,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (achievementId != null) 'achievement_id': achievementId,
      if (currentCount != null) 'current_count': currentCount,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  UserAchievementsCompanion copyWith({
    Value<int>? id,
    Value<int>? achievementId,
    Value<int>? currentCount,
    Value<bool>? isUnlocked,
    Value<DateTime?>? unlockedAt,
  }) {
    return UserAchievementsCompanion(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      currentCount: currentCount ?? this.currentCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (achievementId.present) {
      map['achievement_id'] = Variable<int>(achievementId.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('currentCount: $currentCount, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $FoodProductsTable foodProducts = $FoodProductsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $WaterEntriesTable waterEntries = $WaterEntriesTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $MealPlansTable mealPlans = $MealPlansTable(this);
  late final $MealPlanItemsTable mealPlanItems = $MealPlanItemsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $UserAchievementsTable userAchievements = $UserAchievementsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    foodProducts,
    diaryEntries,
    waterEntries,
    weightEntries,
    recipes,
    recipeIngredients,
    mealPlans,
    mealPlanItems,
    achievements,
    userAchievements,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String name,
      required DateTime birthDate,
      required String gender,
      required double heightCm,
      required double currentWeightKg,
      required double targetWeightKg,
      required String activityLevel,
      required String goalType,
      Value<double> weeklyRateKg,
      required int targetCalories,
      required double targetProteinG,
      required double targetFatG,
      required double targetCarbsG,
      required int targetWaterMl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> birthDate,
      Value<String> gender,
      Value<double> heightCm,
      Value<double> currentWeightKg,
      Value<double> targetWeightKg,
      Value<String> activityLevel,
      Value<String> goalType,
      Value<double> weeklyRateKg,
      Value<int> targetCalories,
      Value<double> targetProteinG,
      Value<double> targetFatG,
      Value<double> targetCarbsG,
      Value<int> targetWaterMl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetProteinG => $composableBuilder(
    column: $table.targetProteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetFatG => $composableBuilder(
    column: $table.targetFatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetCarbsG => $composableBuilder(
    column: $table.targetCarbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWaterMl => $composableBuilder(
    column: $table.targetWaterMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetProteinG => $composableBuilder(
    column: $table.targetProteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetFatG => $composableBuilder(
    column: $table.targetFatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetCarbsG => $composableBuilder(
    column: $table.targetCarbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWaterMl => $composableBuilder(
    column: $table.targetWaterMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCalories => $composableBuilder(
    column: $table.targetCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetProteinG => $composableBuilder(
    column: $table.targetProteinG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetFatG => $composableBuilder(
    column: $table.targetFatG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetCarbsG => $composableBuilder(
    column: $table.targetCarbsG,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetWaterMl => $composableBuilder(
    column: $table.targetWaterMl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> currentWeightKg = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<String> activityLevel = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<double> weeklyRateKg = const Value.absent(),
                Value<int> targetCalories = const Value.absent(),
                Value<double> targetProteinG = const Value.absent(),
                Value<double> targetFatG = const Value.absent(),
                Value<double> targetCarbsG = const Value.absent(),
                Value<int> targetWaterMl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                gender: gender,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                activityLevel: activityLevel,
                goalType: goalType,
                weeklyRateKg: weeklyRateKg,
                targetCalories: targetCalories,
                targetProteinG: targetProteinG,
                targetFatG: targetFatG,
                targetCarbsG: targetCarbsG,
                targetWaterMl: targetWaterMl,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime birthDate,
                required String gender,
                required double heightCm,
                required double currentWeightKg,
                required double targetWeightKg,
                required String activityLevel,
                required String goalType,
                Value<double> weeklyRateKg = const Value.absent(),
                required int targetCalories,
                required double targetProteinG,
                required double targetFatG,
                required double targetCarbsG,
                required int targetWaterMl,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                gender: gender,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                activityLevel: activityLevel,
                goalType: goalType,
                weeklyRateKg: weeklyRateKg,
                targetCalories: targetCalories,
                targetProteinG: targetProteinG,
                targetFatG: targetFatG,
                targetCarbsG: targetCarbsG,
                targetWaterMl: targetWaterMl,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$FoodProductsTableCreateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> brand,
      required double caloriesPer100g,
      required double proteinPer100g,
      required double fatPer100g,
      required double carbsPer100g,
      Value<double?> fiberPer100g,
      Value<String> category,
      Value<String> sourceType,
      Value<String?> barcode,
      Value<bool> isFavorite,
      Value<double> servingSizeG,
      Value<DateTime> createdAt,
    });
typedef $$FoodProductsTableUpdateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> brand,
      Value<double> caloriesPer100g,
      Value<double> proteinPer100g,
      Value<double> fatPer100g,
      Value<double> carbsPer100g,
      Value<double?> fiberPer100g,
      Value<String> category,
      Value<String> sourceType,
      Value<String?> barcode,
      Value<bool> isFavorite,
      Value<double> servingSizeG,
      Value<DateTime> createdAt,
    });

class $$FoodProductsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingSizeG => $composableBuilder(
    column: $table.servingSizeG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingSizeG => $composableBuilder(
    column: $table.servingSizeG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableAnnotationComposer({
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

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingSizeG => $composableBuilder(
    column: $table.servingSizeG,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodProductsTable,
          FoodProduct,
          $$FoodProductsTableFilterComposer,
          $$FoodProductsTableOrderingComposer,
          $$FoodProductsTableAnnotationComposer,
          $$FoodProductsTableCreateCompanionBuilder,
          $$FoodProductsTableUpdateCompanionBuilder,
          (
            FoodProduct,
            BaseReferences<_$AppDatabase, $FoodProductsTable, FoodProduct>,
          ),
          FoodProduct,
          PrefetchHooks Function()
        > {
  $$FoodProductsTableTableManager(_$AppDatabase db, $FoodProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double> caloriesPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> carbsPer100g = const Value.absent(),
                Value<double?> fiberPer100g = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<double> servingSizeG = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodProductsCompanion(
                id: id,
                name: name,
                brand: brand,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                fatPer100g: fatPer100g,
                carbsPer100g: carbsPer100g,
                fiberPer100g: fiberPer100g,
                category: category,
                sourceType: sourceType,
                barcode: barcode,
                isFavorite: isFavorite,
                servingSizeG: servingSizeG,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required double caloriesPer100g,
                required double proteinPer100g,
                required double fatPer100g,
                required double carbsPer100g,
                Value<double?> fiberPer100g = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<double> servingSizeG = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodProductsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                fatPer100g: fatPer100g,
                carbsPer100g: carbsPer100g,
                fiberPer100g: fiberPer100g,
                category: category,
                sourceType: sourceType,
                barcode: barcode,
                isFavorite: isFavorite,
                servingSizeG: servingSizeG,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodProductsTable,
      FoodProduct,
      $$FoodProductsTableFilterComposer,
      $$FoodProductsTableOrderingComposer,
      $$FoodProductsTableAnnotationComposer,
      $$FoodProductsTableCreateCompanionBuilder,
      $$FoodProductsTableUpdateCompanionBuilder,
      (
        FoodProduct,
        BaseReferences<_$AppDatabase, $FoodProductsTable, FoodProduct>,
      ),
      FoodProduct,
      PrefetchHooks Function()
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required String mealType,
      required int foodProductId,
      required String customName,
      required double grams,
      required double calculatedCalories,
      required double calculatedProtein,
      required double calculatedFat,
      required double calculatedCarbs,
      required DateTime entryDate,
      Value<DateTime> timestamp,
      Value<String?> notes,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<String> mealType,
      Value<int> foodProductId,
      Value<String> customName,
      Value<double> grams,
      Value<double> calculatedCalories,
      Value<double> calculatedProtein,
      Value<double> calculatedFat,
      Value<double> calculatedCarbs,
      Value<DateTime> entryDate,
      Value<DateTime> timestamp,
      Value<String?> notes,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calculatedCalories => $composableBuilder(
    column: $table.calculatedCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calculatedProtein => $composableBuilder(
    column: $table.calculatedProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calculatedFat => $composableBuilder(
    column: $table.calculatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calculatedCarbs => $composableBuilder(
    column: $table.calculatedCarbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calculatedCalories => $composableBuilder(
    column: $table.calculatedCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calculatedProtein => $composableBuilder(
    column: $table.calculatedProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calculatedFat => $composableBuilder(
    column: $table.calculatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calculatedCarbs => $composableBuilder(
    column: $table.calculatedCarbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get calculatedCalories => $composableBuilder(
    column: $table.calculatedCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calculatedProtein => $composableBuilder(
    column: $table.calculatedProtein,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calculatedFat => $composableBuilder(
    column: $table.calculatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calculatedCarbs => $composableBuilder(
    column: $table.calculatedCarbs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            DiaryEntry,
            BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry>,
          ),
          DiaryEntry,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<int> foodProductId = const Value.absent(),
                Value<String> customName = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> calculatedCalories = const Value.absent(),
                Value<double> calculatedProtein = const Value.absent(),
                Value<double> calculatedFat = const Value.absent(),
                Value<double> calculatedCarbs = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                mealType: mealType,
                foodProductId: foodProductId,
                customName: customName,
                grams: grams,
                calculatedCalories: calculatedCalories,
                calculatedProtein: calculatedProtein,
                calculatedFat: calculatedFat,
                calculatedCarbs: calculatedCarbs,
                entryDate: entryDate,
                timestamp: timestamp,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mealType,
                required int foodProductId,
                required String customName,
                required double grams,
                required double calculatedCalories,
                required double calculatedProtein,
                required double calculatedFat,
                required double calculatedCarbs,
                required DateTime entryDate,
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                mealType: mealType,
                foodProductId: foodProductId,
                customName: customName,
                grams: grams,
                calculatedCalories: calculatedCalories,
                calculatedProtein: calculatedProtein,
                calculatedFat: calculatedFat,
                calculatedCarbs: calculatedCarbs,
                entryDate: entryDate,
                timestamp: timestamp,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        DiaryEntry,
        BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry>,
      ),
      DiaryEntry,
      PrefetchHooks Function()
    >;
typedef $$WaterEntriesTableCreateCompanionBuilder =
    WaterEntriesCompanion Function({
      Value<int> id,
      required int amountMl,
      required DateTime entryDate,
      Value<DateTime> timestamp,
    });
typedef $$WaterEntriesTableUpdateCompanionBuilder =
    WaterEntriesCompanion Function({
      Value<int> id,
      Value<int> amountMl,
      Value<DateTime> entryDate,
      Value<DateTime> timestamp,
    });

class $$WaterEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WaterEntriesTable> {
  $$WaterEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterEntriesTable> {
  $$WaterEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterEntriesTable> {
  $$WaterEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$WaterEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterEntriesTable,
          WaterEntry,
          $$WaterEntriesTableFilterComposer,
          $$WaterEntriesTableOrderingComposer,
          $$WaterEntriesTableAnnotationComposer,
          $$WaterEntriesTableCreateCompanionBuilder,
          $$WaterEntriesTableUpdateCompanionBuilder,
          (
            WaterEntry,
            BaseReferences<_$AppDatabase, $WaterEntriesTable, WaterEntry>,
          ),
          WaterEntry,
          PrefetchHooks Function()
        > {
  $$WaterEntriesTableTableManager(_$AppDatabase db, $WaterEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountMl = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WaterEntriesCompanion(
                id: id,
                amountMl: amountMl,
                entryDate: entryDate,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountMl,
                required DateTime entryDate,
                Value<DateTime> timestamp = const Value.absent(),
              }) => WaterEntriesCompanion.insert(
                id: id,
                amountMl: amountMl,
                entryDate: entryDate,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterEntriesTable,
      WaterEntry,
      $$WaterEntriesTableFilterComposer,
      $$WaterEntriesTableOrderingComposer,
      $$WaterEntriesTableAnnotationComposer,
      $$WaterEntriesTableCreateCompanionBuilder,
      $$WaterEntriesTableUpdateCompanionBuilder,
      (
        WaterEntry,
        BaseReferences<_$AppDatabase, $WaterEntriesTable, WaterEntry>,
      ),
      WaterEntry,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<int> id,
      required double weightKg,
      required DateTime entryDate,
      Value<String?> notes,
      Value<DateTime> timestamp,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<int> id,
      Value<double> weightKg,
      Value<DateTime> entryDate,
      Value<String?> notes,
      Value<DateTime> timestamp,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightEntry,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            WeightEntry,
            BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
          ),
          WeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WeightEntriesCompanion(
                id: id,
                weightKg: weightKg,
                entryDate: entryDate,
                notes: notes,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double weightKg,
                required DateTime entryDate,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                id: id,
                weightKg: weightKg,
                entryDate: entryDate,
                notes: notes,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightEntry,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        WeightEntry,
        BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
      ),
      WeightEntry,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int> prepTimeMinutes,
      Value<int> servings,
      Value<String> category,
      Value<bool> isFavorite,
      Value<String?> imageUrl,
      Value<DateTime> createdAt,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int> prepTimeMinutes,
      Value<int> servings,
      Value<String> category,
      Value<bool> isFavorite,
      Value<String?> imageUrl,
      Value<DateTime> createdAt,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
          Recipe,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> prepTimeMinutes = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                description: description,
                prepTimeMinutes: prepTimeMinutes,
                servings: servings,
                category: category,
                isFavorite: isFavorite,
                imageUrl: imageUrl,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> prepTimeMinutes = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                description: description,
                prepTimeMinutes: prepTimeMinutes,
                servings: servings,
                category: category,
                isFavorite: isFavorite,
                imageUrl: imageUrl,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
      Recipe,
      PrefetchHooks Function()
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required int recipeId,
      required int foodProductId,
      required double grams,
      Value<String?> notes,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int> foodProductId,
      Value<double> grams,
      Value<String?> notes,
    });

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get foodProductId => $composableBuilder(
    column: $table.foodProductId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (
            RecipeIngredient,
            BaseReferences<
              _$AppDatabase,
              $RecipeIngredientsTable,
              RecipeIngredient
            >,
          ),
          RecipeIngredient,
          PrefetchHooks Function()
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int> foodProductId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                foodProductId: foodProductId,
                grams: grams,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required int foodProductId,
                required double grams,
                Value<String?> notes = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                foodProductId: foodProductId,
                grams: grams,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (
        RecipeIngredient,
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        >,
      ),
      RecipeIngredient,
      PrefetchHooks Function()
    >;
typedef $$MealPlansTableCreateCompanionBuilder =
    MealPlansCompanion Function({
      Value<int> id,
      required DateTime weekStartDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$MealPlansTableUpdateCompanionBuilder =
    MealPlansCompanion Function({
      Value<int> id,
      Value<DateTime> weekStartDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$MealPlansTableFilterComposer
    extends Composer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MealPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealPlansTable,
          MealPlan,
          $$MealPlansTableFilterComposer,
          $$MealPlansTableOrderingComposer,
          $$MealPlansTableAnnotationComposer,
          $$MealPlansTableCreateCompanionBuilder,
          $$MealPlansTableUpdateCompanionBuilder,
          (MealPlan, BaseReferences<_$AppDatabase, $MealPlansTable, MealPlan>),
          MealPlan,
          PrefetchHooks Function()
        > {
  $$MealPlansTableTableManager(_$AppDatabase db, $MealPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> weekStartDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MealPlansCompanion(
                id: id,
                weekStartDate: weekStartDate,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime weekStartDate,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MealPlansCompanion.insert(
                id: id,
                weekStartDate: weekStartDate,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealPlansTable,
      MealPlan,
      $$MealPlansTableFilterComposer,
      $$MealPlansTableOrderingComposer,
      $$MealPlansTableAnnotationComposer,
      $$MealPlansTableCreateCompanionBuilder,
      $$MealPlansTableUpdateCompanionBuilder,
      (MealPlan, BaseReferences<_$AppDatabase, $MealPlansTable, MealPlan>),
      MealPlan,
      PrefetchHooks Function()
    >;
typedef $$MealPlanItemsTableCreateCompanionBuilder =
    MealPlanItemsCompanion Function({
      Value<int> id,
      required int mealPlanId,
      Value<int?> recipeId,
      required DateTime plannedDate,
      required String mealType,
      Value<String?> customNote,
      Value<double> servings,
    });
typedef $$MealPlanItemsTableUpdateCompanionBuilder =
    MealPlanItemsCompanion Function({
      Value<int> id,
      Value<int> mealPlanId,
      Value<int?> recipeId,
      Value<DateTime> plannedDate,
      Value<String> mealType,
      Value<String?> customNote,
      Value<double> servings,
    });

class $$MealPlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealPlanId => $composableBuilder(
    column: $table.mealPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealPlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealPlanId => $composableBuilder(
    column: $table.mealPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealPlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealPlanId => $composableBuilder(
    column: $table.mealPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);
}

class $$MealPlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealPlanItemsTable,
          MealPlanItem,
          $$MealPlanItemsTableFilterComposer,
          $$MealPlanItemsTableOrderingComposer,
          $$MealPlanItemsTableAnnotationComposer,
          $$MealPlanItemsTableCreateCompanionBuilder,
          $$MealPlanItemsTableUpdateCompanionBuilder,
          (
            MealPlanItem,
            BaseReferences<_$AppDatabase, $MealPlanItemsTable, MealPlanItem>,
          ),
          MealPlanItem,
          PrefetchHooks Function()
        > {
  $$MealPlanItemsTableTableManager(_$AppDatabase db, $MealPlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealPlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealPlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealPlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mealPlanId = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                Value<DateTime> plannedDate = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<String?> customNote = const Value.absent(),
                Value<double> servings = const Value.absent(),
              }) => MealPlanItemsCompanion(
                id: id,
                mealPlanId: mealPlanId,
                recipeId: recipeId,
                plannedDate: plannedDate,
                mealType: mealType,
                customNote: customNote,
                servings: servings,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mealPlanId,
                Value<int?> recipeId = const Value.absent(),
                required DateTime plannedDate,
                required String mealType,
                Value<String?> customNote = const Value.absent(),
                Value<double> servings = const Value.absent(),
              }) => MealPlanItemsCompanion.insert(
                id: id,
                mealPlanId: mealPlanId,
                recipeId: recipeId,
                plannedDate: plannedDate,
                mealType: mealType,
                customNote: customNote,
                servings: servings,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealPlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealPlanItemsTable,
      MealPlanItem,
      $$MealPlanItemsTableFilterComposer,
      $$MealPlanItemsTableOrderingComposer,
      $$MealPlanItemsTableAnnotationComposer,
      $$MealPlanItemsTableCreateCompanionBuilder,
      $$MealPlanItemsTableUpdateCompanionBuilder,
      (
        MealPlanItem,
        BaseReferences<_$AppDatabase, $MealPlanItemsTable, MealPlanItem>,
      ),
      MealPlanItem,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required String key,
      required String title,
      required String description,
      required String iconName,
      Value<int> requiredCount,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> title,
      Value<String> description,
      Value<String> iconName,
      Value<int> requiredCount,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requiredCount => $composableBuilder(
    column: $table.requiredCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requiredCount => $composableBuilder(
    column: $table.requiredCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get requiredCount => $composableBuilder(
    column: $table.requiredCount,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> requiredCount = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                key: key,
                title: title,
                description: description,
                iconName: iconName,
                requiredCount: requiredCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String title,
                required String description,
                required String iconName,
                Value<int> requiredCount = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                key: key,
                title: title,
                description: description,
                iconName: iconName,
                requiredCount: requiredCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$UserAchievementsTableCreateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      required int achievementId,
      Value<int> currentCount,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
    });
typedef $$UserAchievementsTableUpdateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      Value<int> achievementId,
      Value<int> currentCount,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
    });

class $$UserAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$UserAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAchievementsTable,
          UserAchievement,
          $$UserAchievementsTableFilterComposer,
          $$UserAchievementsTableOrderingComposer,
          $$UserAchievementsTableAnnotationComposer,
          $$UserAchievementsTableCreateCompanionBuilder,
          $$UserAchievementsTableUpdateCompanionBuilder,
          (
            UserAchievement,
            BaseReferences<
              _$AppDatabase,
              $UserAchievementsTable,
              UserAchievement
            >,
          ),
          UserAchievement,
          PrefetchHooks Function()
        > {
  $$UserAchievementsTableTableManager(
    _$AppDatabase db,
    $UserAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> achievementId = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => UserAchievementsCompanion(
                id: id,
                achievementId: achievementId,
                currentCount: currentCount,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int achievementId,
                Value<int> currentCount = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => UserAchievementsCompanion.insert(
                id: id,
                achievementId: achievementId,
                currentCount: currentCount,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAchievementsTable,
      UserAchievement,
      $$UserAchievementsTableFilterComposer,
      $$UserAchievementsTableOrderingComposer,
      $$UserAchievementsTableAnnotationComposer,
      $$UserAchievementsTableCreateCompanionBuilder,
      $$UserAchievementsTableUpdateCompanionBuilder,
      (
        UserAchievement,
        BaseReferences<_$AppDatabase, $UserAchievementsTable, UserAchievement>,
      ),
      UserAchievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$FoodProductsTableTableManager get foodProducts =>
      $$FoodProductsTableTableManager(_db, _db.foodProducts);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$WaterEntriesTableTableManager get waterEntries =>
      $$WaterEntriesTableTableManager(_db, _db.waterEntries);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$MealPlansTableTableManager get mealPlans =>
      $$MealPlansTableTableManager(_db, _db.mealPlans);
  $$MealPlanItemsTableTableManager get mealPlanItems =>
      $$MealPlanItemsTableTableManager(_db, _db.mealPlanItems);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$UserAchievementsTableTableManager get userAchievements =>
      $$UserAchievementsTableTableManager(_db, _db.userAchievements);
}
