import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/car_model.dart';
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String user_id,
    required String name,
    required String email,
    required String fcm_token,
    required String role,
    required String profile_image,
    CarModel? car,
    AddressModel? current_address,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // @override
  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_id': user_id,
  //     'name': name,
  //     'email': email,
  //     'fcm_token': fcm_token,
  //     'role': role,
  //     'profile_image': profile_image,
  //     'car': car!.toJson(),
  //     'current_address': current_address!.toJson(),
  //   };
  // }
}
