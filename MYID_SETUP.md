# MyID SDK Setup Guide

## 1. Maven Repository
To use the MyID SDK, you must add the following Maven repository to your `android/build.gradle.kts` (or `android/build.gradle`) file in the `allprojects` section:

```kotlin
maven { url = uri("https://artifactory.aigroup.uz:443/artifactory/myid/") }
```

This is necessary because the MyID Android SDK is hosted on a private Artifactory server, not on Maven Central.

## 2. Minimum SDK Version
MyID SDK requires a minimum Android SDK version of **23** (Android 6.0). 
Ensure your `android/app/build.gradle.kts` has:

```kotlin
defaultConfig {
    minSdk = 23
    // ...
}
```

## 3. Flutter Dependencies
Ensure `pubspec.yaml` points to the correct package (local or pub):

```yaml
dependencies:
  myid:
    path: ../myid-3.1.41 # If using local offline package
    # or
    # myid: ^3.1.41 # If using pub.dev
```

## 4. Build
Run `flutter build apk` to compile.
