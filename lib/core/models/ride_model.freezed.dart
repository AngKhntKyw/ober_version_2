// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RideModel _$RideModelFromJson(Map<String, dynamic> json) {
  return _RideModel.fromJson(json);
}

/// @nodoc
mixin _$RideModel {
  String get id => throw _privateConstructorUsedError;
  UserModel get passenger => throw _privateConstructorUsedError;
  AddressModel get pick_up => throw _privateConstructorUsedError;
  AddressModel get destination => throw _privateConstructorUsedError;
  int get fare => throw _privateConstructorUsedError;
  String get distance => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  UserModel? get driver => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RideModelCopyWith<RideModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideModelCopyWith<$Res> {
  factory $RideModelCopyWith(RideModel value, $Res Function(RideModel) then) =
      _$RideModelCopyWithImpl<$Res, RideModel>;
  @useResult
  $Res call(
      {String id,
      UserModel passenger,
      AddressModel pick_up,
      AddressModel destination,
      int fare,
      String distance,
      String duration,
      String status,
      UserModel? driver});

  $UserModelCopyWith<$Res> get passenger;
  $AddressModelCopyWith<$Res> get pick_up;
  $AddressModelCopyWith<$Res> get destination;
  $UserModelCopyWith<$Res>? get driver;
}

/// @nodoc
class _$RideModelCopyWithImpl<$Res, $Val extends RideModel>
    implements $RideModelCopyWith<$Res> {
  _$RideModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? passenger = null,
    Object? pick_up = null,
    Object? destination = null,
    Object? fare = null,
    Object? distance = null,
    Object? duration = null,
    Object? status = null,
    Object? driver = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      passenger: null == passenger
          ? _value.passenger
          : passenger // ignore: cast_nullable_to_non_nullable
              as UserModel,
      pick_up: null == pick_up
          ? _value.pick_up
          : pick_up // ignore: cast_nullable_to_non_nullable
              as AddressModel,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as AddressModel,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as int,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get passenger {
    return $UserModelCopyWith<$Res>(_value.passenger, (value) {
      return _then(_value.copyWith(passenger: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AddressModelCopyWith<$Res> get pick_up {
    return $AddressModelCopyWith<$Res>(_value.pick_up, (value) {
      return _then(_value.copyWith(pick_up: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AddressModelCopyWith<$Res> get destination {
    return $AddressModelCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get driver {
    if (_value.driver == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.driver!, (value) {
      return _then(_value.copyWith(driver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RideModelImplCopyWith<$Res>
    implements $RideModelCopyWith<$Res> {
  factory _$$RideModelImplCopyWith(
          _$RideModelImpl value, $Res Function(_$RideModelImpl) then) =
      __$$RideModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      UserModel passenger,
      AddressModel pick_up,
      AddressModel destination,
      int fare,
      String distance,
      String duration,
      String status,
      UserModel? driver});

  @override
  $UserModelCopyWith<$Res> get passenger;
  @override
  $AddressModelCopyWith<$Res> get pick_up;
  @override
  $AddressModelCopyWith<$Res> get destination;
  @override
  $UserModelCopyWith<$Res>? get driver;
}

/// @nodoc
class __$$RideModelImplCopyWithImpl<$Res>
    extends _$RideModelCopyWithImpl<$Res, _$RideModelImpl>
    implements _$$RideModelImplCopyWith<$Res> {
  __$$RideModelImplCopyWithImpl(
      _$RideModelImpl _value, $Res Function(_$RideModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? passenger = null,
    Object? pick_up = null,
    Object? destination = null,
    Object? fare = null,
    Object? distance = null,
    Object? duration = null,
    Object? status = null,
    Object? driver = freezed,
  }) {
    return _then(_$RideModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      passenger: null == passenger
          ? _value.passenger
          : passenger // ignore: cast_nullable_to_non_nullable
              as UserModel,
      pick_up: null == pick_up
          ? _value.pick_up
          : pick_up // ignore: cast_nullable_to_non_nullable
              as AddressModel,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as AddressModel,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as int,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RideModelImpl extends _RideModel {
  const _$RideModelImpl(
      {required this.id,
      required this.passenger,
      required this.pick_up,
      required this.destination,
      required this.fare,
      required this.distance,
      required this.duration,
      required this.status,
      this.driver})
      : super._();

  factory _$RideModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideModelImplFromJson(json);

  @override
  final String id;
  @override
  final UserModel passenger;
  @override
  final AddressModel pick_up;
  @override
  final AddressModel destination;
  @override
  final int fare;
  @override
  final String distance;
  @override
  final String duration;
  @override
  final String status;
  @override
  final UserModel? driver;

  @override
  String toString() {
    return 'RideModel(id: $id, passenger: $passenger, pick_up: $pick_up, destination: $destination, fare: $fare, distance: $distance, duration: $duration, status: $status, driver: $driver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.passenger, passenger) ||
                other.passenger == passenger) &&
            (identical(other.pick_up, pick_up) || other.pick_up == pick_up) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.fare, fare) || other.fare == fare) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.driver, driver) || other.driver == driver));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, passenger, pick_up,
      destination, fare, distance, duration, status, driver);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideModelImplCopyWith<_$RideModelImpl> get copyWith =>
      __$$RideModelImplCopyWithImpl<_$RideModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideModelImplToJson(
      this,
    );
  }
}

abstract class _RideModel extends RideModel {
  const factory _RideModel(
      {required final String id,
      required final UserModel passenger,
      required final AddressModel pick_up,
      required final AddressModel destination,
      required final int fare,
      required final String distance,
      required final String duration,
      required final String status,
      final UserModel? driver}) = _$RideModelImpl;
  const _RideModel._() : super._();

  factory _RideModel.fromJson(Map<String, dynamic> json) =
      _$RideModelImpl.fromJson;

  @override
  String get id;
  @override
  UserModel get passenger;
  @override
  AddressModel get pick_up;
  @override
  AddressModel get destination;
  @override
  int get fare;
  @override
  String get distance;
  @override
  String get duration;
  @override
  String get status;
  @override
  UserModel? get driver;
  @override
  @JsonKey(ignore: true)
  _$$RideModelImplCopyWith<_$RideModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
