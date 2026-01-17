import 'enums.dart';

part 'myid_config.g.dart';

class MyIdConfig {
  final String? sessionId;
  final String? clientHash;
  final String? clientHashId;
  final int? minAge;
  final double? distance;
  final MyIdResidency? residency;
  final MyIdEnvironment? environment;
  final MyIdEntryType? entryType;
  final MyIdLocale? locale;
  final MyIdCameraShape? cameraShape;
  final MyIdCameraSelector? cameraSelector;
  final MyIdCameraResolution? cameraResolution;
  final MyIdImageFormat? imageFormat;
  final MyIdPresentationStyle? presentationStyle;
  final MyIdOrganizationDetails? organizationDetails;
  final bool? withSoundGuides;
  final bool? showErrorScreen;
  final String? huaweiAppId;

  MyIdConfig({
    this.sessionId,
    this.clientHash,
    this.clientHashId,
    this.minAge,
    this.distance,
    this.residency,
    this.environment,
    this.entryType,
    this.locale,
    this.cameraShape,
    this.cameraSelector,
    this.cameraResolution,
    this.imageFormat,
    this.presentationStyle,
    this.organizationDetails,
    this.withSoundGuides,
    this.showErrorScreen,
    this.huaweiAppId,
  });

  factory MyIdConfig.fromJson(Map<String, dynamic> json) =>
      _$MyIdConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MyIdConfigToJson(this);
}

class MyIdResult {
  final String? code;
  final String? base64;

  MyIdResult({
    this.code,
    this.base64
  });

  factory MyIdResult.fromJson(Map<String, dynamic> json) =>
      _$MyIdResultFromJson(json);
}

class MyIdOrganizationDetails {
  final String? phone;
  final String? logo;

  const MyIdOrganizationDetails({
    required this.phone,
    required this.logo
  });

  factory MyIdOrganizationDetails.fromJson(Map<String, dynamic> json) =>
      _$MyIdOrganizationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$MyIdOrganizationDetailsToJson(this);
}

class MyIdIOSAppearance {
  final String? colorPrimary;
  final String? colorOnPrimary;
  final String? colorError;
  final String? colorOnError;
  final String? colorOutline;
  final String? colorDivider;
  final String? colorSuccess;
  final String? colorButtonContainer;
  final String? colorButtonContainerDisabled;
  final String? colorButtonContent;
  final String? colorButtonContentDisabled;
  final String? colorScanButtonContainer;
  final int? buttonCornerRadius;

  const MyIdIOSAppearance({
    this.colorPrimary,
    this.colorOnPrimary,
    this.colorError,
    this.colorOnError,
    this.colorOutline,
    this.colorDivider,
    this.colorSuccess,
    this.colorButtonContainer,
    this.colorButtonContainerDisabled,
    this.colorButtonContent,
    this.colorButtonContentDisabled,
    this.colorScanButtonContainer,
    this.buttonCornerRadius,
  });

  factory MyIdIOSAppearance.fromJson(Map<String, dynamic> json) =>
      _$MyIdIOSAppearanceFromJson(json);

  Map<String, dynamic> toJson() => _$MyIdIOSAppearanceToJson(this);
}
