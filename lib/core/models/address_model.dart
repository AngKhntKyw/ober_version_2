import 'package:freezed_annotation/freezed_annotation.dart';
part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const AddressModel._();

  const factory AddressModel({
    required String name,
    required double latitude,
    required double longitude,
    required double rotation,
    required double speed,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}
