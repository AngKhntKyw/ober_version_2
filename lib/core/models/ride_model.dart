import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

@freezed
class RideModel with _$RideModel {
  const RideModel._();

  const factory RideModel({
    required String id,
    required UserModel passenger,
    required AddressModel pick_up,
    required AddressModel destination,
    required int fare,
    required String distance,
    required String duration,
    required String status,
    UserModel? driver,
  }) = _RideModel;

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger': passenger.toJson(), // Convert nested UserModel to JSON
      'pick_up': pick_up.toJson(), // Convert nested AddressModel to JSON
      'destination':
          destination.toJson(), // Convert nested AddressModel to JSON
      'fare': fare,
      'distance': distance,
      'duration': duration,
      'status': status,
      'driver': driver?.toJson(), // Convert optional driver model if present
    };
  }
}
