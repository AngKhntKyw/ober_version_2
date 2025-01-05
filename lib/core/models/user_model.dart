import 'package:freezed_annotation/freezed_annotation.dart';
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object> json) =>
      _$UserModelFromJson(json);
}
