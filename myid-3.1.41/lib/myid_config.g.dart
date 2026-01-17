// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myid_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyIdConfig _$MyIdConfigFromJson(Map<String, dynamic> json) {
  return MyIdConfig(
    sessionId: json['sessionId'] as String,
    clientHash: json['clientHash'] as String,
    clientHashId: json['clientHashId'] as String,
    minAge: json['minAge'] as int,
    distance: json['distance'] as double,
    residency: _$enumDecodeNullable(_$MyIdResidencyEnumMap, json['residency']),
    environment: _$enumDecodeNullable(_$MyIdEnvironmentEnumMap, json['environment']),
    entryType: _$enumDecodeNullable(_$MyIdEntryTypeEnumMap, json['entryType']),
    locale: _$enumDecodeNullable(_$MyIdLocaleEnumMap, json['locale']),
    cameraShape: _$enumDecodeNullable(_$MyIdCameraShapeEnumMap, json['cameraShape']),
    cameraSelector: _$enumDecodeNullable(_$MyIdCameraSelectorEnumMap, json['cameraSelector']),
    cameraResolution: _$enumDecodeNullable(_$MyIdCameraResolutionEnumMap, json['cameraResolution']),
    imageFormat: _$enumDecodeNullable(_$MyIdImageFormatEnumMap, json['imageFormat']),
    presentationStyle: _$enumDecodeNullable(_$MyIdPresentationStyleEnumMap, json['presentationStyle']),
    organizationDetails: MyIdOrganizationDetails.fromJson(json['organizationDetails'] as Map<String, dynamic>),
    withSoundGuides: json['withSoundGuides'] as bool?,
    showErrorScreen: json['showErrorScreen'] as bool?,
    huaweiAppId: json['huaweiAppId'] as String,
  );
}

Map<String, dynamic> _$MyIdConfigToJson(MyIdConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sessionId', instance.sessionId);
  writeNotNull('clientHash', instance.clientHash);
  writeNotNull('clientHashId', instance.clientHashId);
  writeNotNull('minAge', instance.minAge);
  writeNotNull('distance', instance.distance);
  writeNotNull('environment', _$MyIdEnvironmentEnumMap[instance.environment]);
  writeNotNull('entryType', _$MyIdEntryTypeEnumMap[instance.entryType]);
  writeNotNull('residency', _$MyIdResidencyEnumMap[instance.residency]);
  writeNotNull('locale', _$MyIdLocaleEnumMap[instance.locale]);
  writeNotNull('cameraShape', _$MyIdCameraShapeEnumMap[instance.cameraShape]);
  writeNotNull('cameraSelector', _$MyIdCameraSelectorEnumMap[instance.cameraSelector]);
  writeNotNull('cameraResolution', _$MyIdCameraResolutionEnumMap[instance.cameraResolution]);
  writeNotNull('imageFormat', _$MyIdImageFormatEnumMap[instance.imageFormat]);
  writeNotNull('presentationStyle', _$MyIdPresentationStyleEnumMap[instance.presentationStyle]);
  writeNotNull('organizationDetails', instance.organizationDetails?.toJson());
  writeNotNull('withSoundGuides', instance.withSoundGuides);
  writeNotNull('showErrorScreen', instance.showErrorScreen);
  writeNotNull('huaweiAppId', instance.huaweiAppId);
  return val;
}

MyIdResult _$MyIdResultFromJson(Map<String, dynamic> json) {
  return MyIdResult(
    code: json['code'] as String?,
    base64: json['base64'] as String?
  );
}

Map<String, dynamic> _$MyIdOrganizationDetailsToJson(MyIdOrganizationDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('phone', instance.phone);
  writeNotNull('logo', instance.logo);
  return val;
}

MyIdOrganizationDetails _$MyIdOrganizationDetailsFromJson(Map<String, dynamic> json) {
  return MyIdOrganizationDetails(
    phone: json['phone'] as String?,
    logo: json['logo'] as String?,
  );
}

Map<String, dynamic> _$MyIdIOSAppearanceToJson(MyIdIOSAppearance instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('colorPrimary', instance.colorPrimary);
  writeNotNull('colorOnPrimary', instance.colorOnPrimary);
  writeNotNull('colorError', instance.colorError);
  writeNotNull('colorOnError', instance.colorOnError);
  writeNotNull('colorOutline', instance.colorOutline);
  writeNotNull('colorDivider', instance.colorDivider);
  writeNotNull('colorSuccess', instance.colorSuccess);
  writeNotNull('colorButtonContainer', instance.colorButtonContainer);
  writeNotNull('colorButtonContainerDisabled', instance.colorButtonContainerDisabled);
  writeNotNull('colorButtonContent', instance.colorButtonContent);
  writeNotNull('colorButtonContentDisabled', instance.colorButtonContentDisabled);
  writeNotNull('colorScanButtonContainer', instance.colorScanButtonContainer);
  writeNotNull('buttonCornerRadius', instance.buttonCornerRadius);
  return val;
}

MyIdIOSAppearance _$MyIdIOSAppearanceFromJson(Map<String, dynamic> json) {
  return MyIdIOSAppearance(
      colorPrimary: json['colorPrimary'] as String?,
      colorOnPrimary: json['colorOnPrimary'] as String?,
      colorError: json['colorError'] as String?,
      colorOnError: json['colorOnError'] as String?,
      colorOutline: json['colorOutline'] as String?,
      colorDivider: json['colorDivider'] as String?,
      colorSuccess: json['colorSuccess'] as String?,
      colorButtonContainer: json['colorButtonContainer'] as String?,
      colorButtonContainerDisabled: json['colorButtonContainerDisabled'] as String?,
      colorButtonContent: json['colorButtonContent'] as String?,
      colorButtonContentDisabled: json['colorButtonContentDisabled'] as String?,
      colorScanButtonContainer: json['colorScanButtonContainer'] as String?,
      buttonCornerRadius: json['buttonCornerRadius'] as int?
  );
}

const _$MyIdEnvironmentEnumMap = {
  MyIdEnvironment.PRODUCTION: 'PRODUCTION',
  MyIdEnvironment.DEBUG: 'DEBUG',
};

const _$MyIdEntryTypeEnumMap = {
  MyIdEntryType.IDENTIFICATION: 'IDENTIFICATION',
  MyIdEntryType.VIDEO_IDENTIFICATION: 'VIDEO_IDENTIFICATION',
  MyIdEntryType.FACE_DETECTION: 'FACE_DETECTION',
};

const _$MyIdResidencyEnumMap = {
  MyIdResidency.USER_DEFINED: 'USER_DEFINED',
  MyIdResidency.RESIDENT: 'RESIDENT',
  MyIdResidency.NON_RESIDENT: 'NON_RESIDENT',
};

const _$MyIdLocaleEnumMap = {
  MyIdLocale.UZBEK: 'UZBEK',
  MyIdLocale.UZBEK_CYRILLIC: 'UZBEK_CYRILLIC',
  MyIdLocale.KARAKALPAK: 'KARAKALPAK',
  MyIdLocale.TAJIK: 'TAJIK',
  MyIdLocale.ENGLISH: 'ENGLISH',
  MyIdLocale.RUSSIAN: 'RUSSIAN',
};

const _$MyIdCameraShapeEnumMap = {
  MyIdCameraShape.CIRCLE: 'CIRCLE',
  MyIdCameraShape.ELLIPSE: 'ELLIPSE',
};

const _$MyIdCameraSelectorEnumMap = {
  MyIdCameraSelector.FRONT: 'FRONT',
  MyIdCameraSelector.BACK: 'BACK',
};

const _$MyIdCameraResolutionEnumMap = {
  MyIdCameraResolution.LOW: 'LOW',
  MyIdCameraResolution.HIGH: 'HIGH',
};

const _$MyIdImageFormatEnumMap = {
  MyIdImageFormat.JPEG: 'JPEG',
  MyIdImageFormat.PNG: 'PNG',
};

const _$MyIdPresentationStyleEnumMap = {
  MyIdPresentationStyle.FULL: 'FULL',
  MyIdPresentationStyle.SHEET: 'SHEET',
};

T? _$enumDecodeNullable<T>(
    Map<T, dynamic> enumValues,
    dynamic source, {
      T? unknownValue,
    }) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

T? _$enumDecode<T>(
    Map<T, dynamic> enumValues,
    dynamic source, {
      T? unknownValue,
    }) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries.singleWhere((e) => e.value == source).key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}