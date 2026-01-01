# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# react-native-reanimated
-keep class com.swmansion.reanimated.** { *; }
-keep class com.facebook.react.turbomodule.** { *; }

# Rename conflicting LicenseContentProvider class to avoid Google Play conflicts
# Repackage the entire com.pairip package to our namespace
-repackageclasses 'com.fuelmateasentyx.app.internal'
-keep class com.pairip.licensecheck.LicenseContentProvider {
    <init>(...);
    <methods>;
    <fields>;
}
# Keep the class but rename the package
-keepnames class com.pairip.licensecheck.LicenseContentProvider

# Add any project specific keep options here:
