// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      user_id: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      fcm_token: json['fcm_token'] as String,
      role: json['role'] as String,
      profile_image: json['profile_image'] as String,
      car: json['car'] == null
          ? null
          : CarModel.fromJson(json['car'] as Map<String, dynamic>),
      current_address: json['current_address'] == null
          ? null
          : AddressModel.fromJson(
              json['current_address'] as Map<String, dynamic>),
      current_ride_id: json['current_ride_id'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'name': instance.name,
      'email': instance.email,
      'fcm_token': instance.fcm_token,
      'role': instance.role,
      'profile_image': instance.profile_image,
      'car': instance.car?.toJson(),
      'current_address': instance.current_address?.toJson(),
      'current_ride_id': instance.current_ride_id,
    };
