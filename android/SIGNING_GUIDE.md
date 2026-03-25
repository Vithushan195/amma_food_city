# Android Signing Configuration

## Signing setup is already partially handled by the build.gradle.
## Follow these steps to generate your keystore and configure signing.

## Step 1: Generate Keystore
## Run this command ONCE and save the .jks file securely:

# keytool -genkey -v -keystore amma-food-city-release.jks \
#   -keyalg RSA -keysize 2048 -validity 10000 \
#   -alias amma_food_city \
#   -storepass YOUR_STORE_PASSWORD \
#   -keypass YOUR_KEY_PASSWORD \
#   -dname "CN=Amma Food City, OU=Mobile, O=Shop Local, L=Paisley, S=Scotland, C=GB"

## Step 2: Create key.properties file
## Save this at android/key.properties (DO NOT commit to git):

# storePassword=YOUR_STORE_PASSWORD
# keyPassword=YOUR_KEY_PASSWORD
# keyAlias=amma_food_city
# storeFile=../../amma-food-city-release.jks

## Step 3: Update android/app/build.gradle
## Add before android { block:

# def keystoreProperties = new Properties()
# def keystorePropertiesFile = rootProject.file('key.properties')
# if (keystorePropertiesFile.exists()) {
#     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
# }

## Add inside android { block:

# signingConfigs {
#     release {
#         keyAlias keystoreProperties['keyAlias']
#         keyPassword keystoreProperties['keyPassword']
#         storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
#         storePassword keystoreProperties['storePassword']
#     }
# }
# buildTypes {
#     release {
#         signingConfig signingConfigs.release
#         minifyEnabled true
#         shrinkResources true
#         proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
#     }
# }

## Step 4: Add to .gitignore
# android/key.properties
# *.jks
# *.keystore
