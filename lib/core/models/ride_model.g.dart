// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RideModelImpl _$$RideModelImplFromJson(Map<String, dynamic> json) =>
    _$RideModelImpl(
      id: json['id'] as String,
      passenger: UserModel.fromJson(json['passenger'] as Map<String, dynamic>),
      pick_up: AddressModel.fromJson(json['pick_up'] as Map<String, dynamic>),
      destination:
          AddressModel.fromJson(json['destination'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toInt(),
      distance: json['distance'] as String,
      duration: json['duration'] as String,
      status: json['status'] as String,
      driver: json['driver'] == null
          ? null
          : UserModel.fromJson(json['driver'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RideModelImplToJson(_$RideModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'passenger': instance.passenger.toJson(),
      'pick_up': instance.pick_up.toJson(),
      'destination': instance.destination.toJson(),
      'fare': instance.fare,
      'distance': instance.distance,
      'duration': instance.duration,
      'status': instance.status,
      'driver': instance.driver?.toJson(),
    };
