import 'package:freezed_annotation/freezed_annotation.dart';
part 'car_model.freezed.dart';
part 'car_model.g.dart';

@freezed
class CarModel with _$CarModel {
  const CarModel._();

  const factory CarModel({
    required String name,
    required String plate_number,
    required String color,
  }) = _CarModel;

  factory CarModel.fromJson(Map<String, dynamic> json) =>
      _$CarModelFromJson(json);
}
