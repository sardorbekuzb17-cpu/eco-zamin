/// MyID foydalanuvchi profili modeli
/// Rasmda ko'rsatilgan barcha maydonlarni qamrab oladi
class MyIdProfileModel {
  // Asosiy ma'lumotlar
  final String? code;
  final String? status;
  final List<String>? attempts;
  final String? jobId;
  final String? timestamp;
  final String? reason;
  final String? reasonCode;

  // Common data (1.4.1)
  final CommonData? commonData;

  // Pers data (1.4.2)
  final PersData? persData;

  // Issued by (1.4.2.3)
  final IssuedBy? issuedBy;

  // Reuid (2)
  final Reuid? reuid;

  MyIdProfileModel({
    this.code,
    this.status,
    this.attempts,
    this.jobId,
    this.timestamp,
    this.reason,
    this.reasonCode,
    this.commonData,
    this.persData,
    this.issuedBy,
    this.reuid,
  });

  factory MyIdProfileModel.fromJson(Map<String, dynamic> json) {
    return MyIdProfileModel(
      code: json['code'],
      status: json['status'],
      attempts: json['attempts'] != null
          ? List<String>.from(json['attempts'])
          : null,
      jobId: json['job_id'],
      timestamp: json['timestamp'],
      reason: json['reason'],
      reasonCode: json['reason_code'],
      commonData: json['common_data'] != null
          ? CommonData.fromJson(json['common_data'])
          : null,
      persData: json['pers_data'] != null
          ? PersData.fromJson(json['pers_data'])
          : null,
      issuedBy: json['issued_by'] != null
          ? IssuedBy.fromJson(json['issued_by'])
          : null,
      reuid: json['reuid'] != null ? Reuid.fromJson(json['reuid']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'attempts': attempts,
      'job_id': jobId,
      'timestamp': timestamp,
      'reason': reason,
      'reason_code': reasonCode,
      'common_data': commonData?.toJson(),
      'pers_data': persData?.toJson(),
      'issued_by': issuedBy?.toJson(),
      'reuid': reuid?.toJson(),
    };
  }
}

/// Common data (1.4.1)
class CommonData {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? pinfl;
  final String? gender;
  final String? birthPlace;
  final String? birthDate;
  final String? nationality;
  final String? citizenship;
  final String? sdkHash;
  final String? lastUpdatePassData;
  final String? docTypeId;
  final String? docTypeIdCbr;

  CommonData({
    this.firstName,
    this.lastName,
    this.middleName,
    this.pinfl,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.nationality,
    this.citizenship,
    this.sdkHash,
    this.lastUpdatePassData,
    this.docTypeId,
    this.docTypeIdCbr,
  });

  factory CommonData.fromJson(Map<String, dynamic> json) {
    return CommonData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      pinfl: json['pinfl'],
      gender: json['gender'],
      birthPlace: json['birth_place'],
      birthDate: json['birth_date'],
      nationality: json['nationality'],
      citizenship: json['citizenship'],
      sdkHash: json['sdk_hash'],
      lastUpdatePassData: json['last_update_pass_data'],
      docTypeId: json['doc_type_id'],
      docTypeIdCbr: json['doc_type_id_cbr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'pinfl': pinfl,
      'gender': gender,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'nationality': nationality,
      'citizenship': citizenship,
      'sdk_hash': sdkHash,
      'last_update_pass_data': lastUpdatePassData,
      'doc_type_id': docTypeId,
      'doc_type_id_cbr': docTypeIdCbr,
    };
  }
}

/// Pers data (1.4.2)
class PersData {
  final String? phone;
  final String? email;
  final Address? address;
  final Address? permanentAddress;
  final Address? temporaryAddress;
  final PermanentRegistration? permanentRegistration;
  final String? mfy;
  final String? mfyId;
  final String? region;
  final String? address2;
  final String? cadstre;
  final String? district;
  final String? regionId;
  final String? countryId;
  final String? districtId;
  final String? regionIdCbr;
  final String? countryIdCbr;
  final String? districtIdCbr;
  final String? registrationDate;
  final TemporaryRegistration? temporaryRegistration;

  PersData({
    this.phone,
    this.email,
    this.address,
    this.permanentAddress,
    this.temporaryAddress,
    this.permanentRegistration,
    this.mfy,
    this.mfyId,
    this.region,
    this.address2,
    this.cadstre,
    this.district,
    this.regionId,
    this.countryId,
    this.districtId,
    this.regionIdCbr,
    this.countryIdCbr,
    this.districtIdCbr,
    this.registrationDate,
    this.temporaryRegistration,
  });

  factory PersData.fromJson(Map<String, dynamic> json) {
    return PersData(
      phone: json['phone'],
      email: json['email'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      permanentAddress: json['permanent_address'] != null
          ? Address.fromJson(json['permanent_address'])
          : null,
      temporaryAddress: json['temporary_address'] != null
          ? Address.fromJson(json['temporary_address'])
          : null,
      permanentRegistration: json['permanent_registration'] != null
          ? PermanentRegistration.fromJson(json['permanent_registration'])
          : null,
      mfy: json['mfy'],
      mfyId: json['mfy_id'],
      region: json['region'],
      address2: json['address'],
      cadstre: json['cadstre'],
      district: json['district'],
      regionId: json['region_id'],
      countryId: json['country_id'],
      districtId: json['district_id'],
      regionIdCbr: json['region_id_cbr'],
      countryIdCbr: json['country_id_cbr'],
      districtIdCbr: json['district_id_cbr'],
      registrationDate: json['registration_date'],
      temporaryRegistration: json['temporary_registration'] != null
          ? TemporaryRegistration.fromJson(json['temporary_registration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'address': address?.toJson(),
      'permanent_address': permanentAddress?.toJson(),
      'temporary_address': temporaryAddress?.toJson(),
      'permanent_registration': permanentRegistration?.toJson(),
      'mfy': mfy,
      'mfy_id': mfyId,
      'region': region,
      'cadstre': cadstre,
      'district': district,
      'region_id': regionId,
      'country_id': countryId,
      'district_id': districtId,
      'region_id_cbr': regionIdCbr,
      'country_id_cbr': countryIdCbr,
      'district_id_cbr': districtIdCbr,
      'registration_date': registrationDate,
      'temporary_registration': temporaryRegistration?.toJson(),
    };
  }
}

/// Address
class Address {
  // Address maydonlari
  final String? fullAddress;
  final String? region;
  final String? district;
  final String? address;

  Address({this.fullAddress, this.region, this.district, this.address});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      fullAddress: json['full_address'],
      region: json['region'],
      district: json['district'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_address': fullAddress,
      'region': region,
      'district': district,
      'address': address,
    };
  }
}

/// Permanent Registration
class PermanentRegistration {
  final String? mfy;
  final String? mfyId;
  final String? region;
  final String? address;
  final String? cadstre;
  final String? district;
  final String? regionId;
  final String? countryId;
  final String? districtId;

  PermanentRegistration({
    this.mfy,
    this.mfyId,
    this.region,
    this.address,
    this.cadstre,
    this.district,
    this.regionId,
    this.countryId,
    this.districtId,
  });

  factory PermanentRegistration.fromJson(Map<String, dynamic> json) {
    return PermanentRegistration(
      mfy: json['mfy'],
      mfyId: json['mfy_id'],
      region: json['region'],
      address: json['address'],
      cadstre: json['cadstre'],
      district: json['district'],
      regionId: json['region_id'],
      countryId: json['country_id'],
      districtId: json['district_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mfy': mfy,
      'mfy_id': mfyId,
      'region': region,
      'address': address,
      'cadstre': cadstre,
      'district': district,
      'region_id': regionId,
      'country_id': countryId,
      'district_id': districtId,
    };
  }
}

/// Temporary Registration
class TemporaryRegistration {
  final String? mfy;
  final String? mfyId;
  final String? region;
  final String? address;
  final String? cadstre;
  final String? district;

  TemporaryRegistration({
    this.mfy,
    this.mfyId,
    this.region,
    this.address,
    this.cadstre,
    this.district,
  });

  factory TemporaryRegistration.fromJson(Map<String, dynamic> json) {
    return TemporaryRegistration(
      mfy: json['mfy'],
      mfyId: json['mfy_id'],
      region: json['region'],
      address: json['address'],
      cadstre: json['cadstre'],
      district: json['district'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mfy': mfy,
      'mfy_id': mfyId,
      'region': region,
      'address': address,
      'cadstre': cadstre,
      'district': district,
    };
  }
}

/// Issued by (1.4.2.3)
class IssuedBy {
  final String? issuedBy;
  final String? issuedDate;
  final String? expiryDate;
  final String? docType;
  final String? docTypeId;
  final String? docTypeIdCbr;

  IssuedBy({
    this.issuedBy,
    this.issuedDate,
    this.expiryDate,
    this.docType,
    this.docTypeId,
    this.docTypeIdCbr,
  });

  factory IssuedBy.fromJson(Map<String, dynamic> json) {
    return IssuedBy(
      issuedBy: json['issued_by'],
      issuedDate: json['issued_date'],
      expiryDate: json['expiry_date'],
      docType: json['doc_type'],
      docTypeId: json['doc_type_id'],
      docTypeIdCbr: json['doc_type_id_cbr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issued_by': issuedBy,
      'issued_date': issuedDate,
      'expiry_date': expiryDate,
      'doc_type': docType,
      'doc_type_id': docTypeId,
      'doc_type_id_cbr': docTypeIdCbr,
    };
  }
}

/// Reuid (2)
class Reuid {
  final String? expiresAt;
  final int? value;

  Reuid({this.expiresAt, this.value});

  factory Reuid.fromJson(Map<String, dynamic> json) {
    return Reuid(expiresAt: json['expires_at'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'expires_at': expiresAt, 'value': value};
  }
}
