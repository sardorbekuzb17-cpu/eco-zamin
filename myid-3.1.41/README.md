# myid

MyID SDK flutter plugin.

## Table of contents

- [Project adjustments](#project-adjustments)
- [Usage](#usage)
- [SDK error codes](#sdk-error-codes)
- [Theme](#theme)

Android SDK: `3.1.3`

iOS SDK: `3.1.2`

## Project adjustments

### iOS

Update your iOS configuration files

Change `ios/Podfile` to use version 13:

```ruby
platform :ios, '13.0'
```

Add descriptions for camera permission to `ios/YourProjectName/Info.plist`:

```xml
<plist version="1.0">
<dict>
  <!-- Add these two elements: -->
    <key>NSCameraUsageDescription</key>
    <string>Required for document and facial capture</string>
  <!-- ... -->
</dict>
</plist>
```

## Usage

```dart
 var result = await MyIdClient.start(
    config: MyIdConfig(
        sessionId: sessionId,
        clientHash: clientHash,
        clientHashId: clientHashId,
        environment: MyIdEnvironment.PRODUCTION
    ),
    iosAppearance: MyIdIOSAppearance(),
);

```

**Parameters details**:

Method | Notes | Default
--- | --- | ---
`sessionId` | Session ID | Provided by MyID sales team. Mandatory, if using entryType = MyIdEntryType.IDENTIFICATION
`clientHash` | Client Hash | Provided by MyID sales team. Mandatory, if using entryType = MyIdEntryType.IDENTIFICATION
`clientHashId` | Client Hash ID | Provided by MyID sales team. Mandatory, if using entryType = MyIdEntryType.IDENTIFICATION
`residency` | To set a specific residency type (Note 1.4) | MyIdResidency.RESIDENT
`environment` | Environment mode (Note 1.1) | MyIdEnvironment.PRODUCTION
`entryType` | Customizing the SDK entry types (Note 1.2) | MyIdEntryType.IDENTIFICATION
`locale` | To set a specific locale | MyIdLocale.UZBEK
`cameraShape` | To set a specific camera shape (Note 1.3) | MyIdCameraShape.CIRCLE
`cameraResolution` | To set a specific camera resolution | MyIdCameraResolution.LOW
`imageFormat` | To set a specific image format | MyIdImageFormat.PNG
`organizationDetails` | Custom Organization Details | Optional
`withSoundGuides` | To set sound guides | true
`showErrorScreen` | Customizing the SDK error screens | true
`huaweiAppId` | To set a huawei app id | Required for HMS

**Note 1.1.** `MyIdEnvironment` contains **DEBUG** and **PRODUCTION** modes.

- **DEBUG** is used to sandbox.
- **PRODUCTION** is used to production.

**Note 1.2.** `MyIdEntryType` contains **IDENTIFICATION** and **FACE_DETECTION** types.

- **IDENTIFICATION** is used to identify the user through the MyID services.
- **FACE_DETECTION** is used to detect a face and returns a picture (bitmap).

**Note 1.3.** `MyIdCameraShape` contains **[CIRCLE](images/screen03.jpg)**
and **[ELLIPSE](images/screen04.jpg)** types.

**Note 1.4.** If the SDK **does not receive a passport data** and receives `residency = MyIdResidency.USER_DEFINED`, the SDK displays the **MyID passport input screen**. If the user enters a **PINFL**, the screen will show a **checkbox** allowing the user to select **Resident** or **Non-Resident**.

## Theme

For [**Android**](https://gitlab.myid.uz/myid-public-code/myid-sample-android/-/blob/master/CUSTOMIZATION.md)

For **iOS** theme config use `MyIdIOSAppearance` class and its properties.

- `colorPrimary`: Defines the color of SDK which guides the user through the flow
- `colorOnPrimary`: Defines the color of text and icons shown on top of the primary color
- `colorError`: Defines the color of error buttons, icons, and states
- `colorOnError`: Defines the color of text and icons shown on top of error backgrounds
- `colorOutline`: Defines the color of borders and outlines for inputs and cards
- `colorDivider`: Defines the color of thin lines separating UI sections
- `colorSuccess`: Defines the color used to show successful actions or states
- `colorButtonContainer`: Defines the background color of the primary action buttons
- `colorButtonContainerDisabled`: Defines the background color of disabled buttons
- `colorButtonContent`: Defines the color of text/icons in primary action buttons
- `colorButtonContentDisabled`: Defines the color of text/icons in disabled buttons
- `colorScanButtonContainer`: Defines the color of scan icon button
- `buttonCornerRadius`: Defines the corner radius of all primary buttons

## Custom Organization Details

You can customize the SDK, for it to match your organization's brand book, by
providing `MyIdOrganizationDetails` object to `organizationDetails` method. The object allows you to
customize following fields:

- *phoneNumber* - by default 712022202, which is MyID's call center. If you would like the customer
  to call your own call center, you can display your own phone number on the error screen, by
  providing it in this field ([sample](images/screen01.jpg)).
- *logo* - the image drawable name, that will be displayed on the input screen. If you would like to
  display your own logo on the top of the screen, this is the place to provide it. Make sure it fits
  the imageView element, which has the *240x60* size.

## SDK error codes

You can view the full list of SDK error codes at:

👉 [Error Codes Documentation](https://docs.myid.uz/#/ru/embedded?id=javob-kodlar-uz-result_code)

The error code in the following list may appear during the call of SDK. The list below is for your
reference.

Code | Error message
:---: | :---
101 | User cancelled flow
102 | Camera access denied
103 | Error while retrieving data from server or SDK
122 | User banned

## Huawei Configuration

MyID SDK supports Huawei devices that use **Huawei Mobile Services (HMS)** instead of **Google Play Services (GMS)**.

If your app runs on Huawei devices (for example, Mate or P series) **without GMS**,
you must add the **MyID Integrity SDK** and configure your Huawei **App ID**.

If this dependency is **missing** and the device **supports HMS**,
the MyID SDK will **crash during initialization**.

### 1. Add the Huawei Integrity SDK

Add the following dependency to your **module-level** `build.gradle` file:

```gradle
dependencies {
    implementation("uz.myid.sdk.capture:myid-integrity-sdk:1.0.6")
}
```

This library enables the SDK to handle Huawei Mobile Services (HMS)
and prevents runtime crashes on Huawei devices.

### 2. Configure the App ID

You need a valid **Huawei App ID** from **AppGallery Connect**.

1. Open [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html).
2. Go to your project → **General information**.
3. Copy your **App ID**.
4. Add it to your `AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data
    android:name="com.huawei.hms.client.appid"
    android:value="appid=YOUR_HUAWEI_APP_ID" />
```

Replace `YOUR_HUAWEI_APP_ID` with your actual App ID.

### 3. Pass Huawei App ID to the SDK

When initializing `MyIdConfig`, include your Huawei App ID using the `huaweiAppId` method:

This ensures that the SDK recognizes and properly initializes HMS support.

## 4. Troubleshooting

Issue | Cause | Solution
--- | --- | ---
SDK crashes on Huawei devices | `myid-integrity-sdk` not added | Add `implementation("uz.myid.sdk.capture:myid-integrity-sdk:1.0.6")`
SDK fails to initialize | Missing App ID | Add `huaweiAppId = "YOUR_HUAWEI_APP_ID"`
Invalid App ID error | Wrong App ID in manifest or SDK | Recheck AppGallery Connect for correct ID
Works on Google devices but not Huawei | HMS dependency missing | Make sure Integrity SDK is included

## Getting Started with Flutter plugins

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
