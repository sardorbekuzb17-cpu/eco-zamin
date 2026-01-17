// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myid_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyIDUser _$MyIDUserFromJson(Map<String, dynamic> json) => MyIDUser(
  userId: json['sub'] as String?,
  firstName: json['given_name'] as String?,
  lastName: json['family_name'] as String?,
  middleName: json['middle_name'] as String?,
  fullName: json['name'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  birthDate: json['birthdate'] as String?,
  gender: json['gender'] as String?,
  pinfl: json['pinfl'] as String?,
  passportSeries: json['passport_series'] as String?,
  passportNumber: json['passport_number'] as String?,
);

Map<String, dynamic> _$MyIDUserToJson(MyIDUser instance) => <String, dynamic>{
  'sub': instance.userId,
  'given_name': instance.firstName,
  'family_name': instance.lastName,
  'middle_name': instance.middleName,
  'name': instance.fullName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'birthdate': instance.birthDate,
  'gender': instance.gender,
  'pinfl': instance.pinfl,
  'passport_series': instance.passportSeries,
  'passport_number': instance.passportNumber,
};
