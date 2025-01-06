import 'package:freezed_annotation/freezed_annotation.dart';
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
