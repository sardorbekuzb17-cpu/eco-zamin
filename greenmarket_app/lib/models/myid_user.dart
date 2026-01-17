import 'package:json_annotation/json_annotation.dart';

part 'myid_user.g.dart';

@JsonSerializable()
class MyIDUser {
  @JsonKey(name: 'sub')
  final String? userId;

  @JsonKey(name: 'given_name')
  final String? firstName;

  @JsonKey(name: 'family_name')
  final String? lastName;

  @JsonKey(name: 'middle_name')
  final String? middleName;

  @JsonKey(name: 'name')
  final String? fullName;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'birthdate')
  final String? birthDate;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'pinfl')
  final String? pinfl;

  @JsonKey(name: 'passport_series')
  final String? passportSeries;

  @JsonKey(name: 'passport_number')
  final String? passportNumber;

  MyIDUser({
    this.userId,
    this.firstName,
    this.lastName,
    this.middleName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.pinfl,
    this.passportSeries,
    this.passportNumber,
  });

  factory MyIDUser.fromJson(Map<String, dynamic> json) =>
      _$MyIDUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyIDUserToJson(this);
}
