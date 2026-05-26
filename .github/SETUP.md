# CI/CD Setup Checklist

## Step 1 — Android signing keystore

Run this once on your machine to generate a keystore file:

```bash
keytool -genkey -v -keystore truthboundary.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias truthboundary
```

It will ask you for passwords and info — save them, you'll need them for secrets.

Then encode it to base64:
```bash
# On Mac/Linux:
base64 -i truthboundary.jks

# On Windows (PowerShell):
[Convert]::ToBase64String([IO.File]::ReadAllBytes("truthboundary.jks"))
```

Copy the output — that's your KEYSTORE_BASE64 secret.

---

## Step 2 — Add GitHub Secrets

Go to: github.com/yboubellouta/TruthBoundary/settings/secrets/actions

Add these secrets:

| Secret name                    | Value                                      |
|--------------------------------|--------------------------------------------|
| KEYSTORE_BASE64                | Base64 output from step 1                  |
| KEYSTORE_PASSWORD              | Password you set for the keystore file     |
| KEY_PASSWORD                   | Password you set for the key alias         |
| KEY_ALIAS                      | truthboundary (or whatever alias you used) |
| PLAY_STORE_SERVICE_ACCOUNT_JSON | Contents of the Google service account JSON (see step 3) |

---

## Step 3 — Google Play service account (for auto-upload)

1. Go to console.cloud.google.com
2. Create a new project (or use existing)
3. Enable the "Google Play Android Developer API"
4. Go to IAM → Service Accounts → Create service account
5. Download the JSON key file
6. Go to play.google.com/console → Setup → API access
7. Link your Google Cloud project
8. Grant the service account "Release manager" permissions
9. Paste the entire JSON file contents into the PLAY_STORE_SERVICE_ACCOUNT_JSON secret

---

## Step 4 — Update android/app/build.gradle

After running `flutter create .`, open android/app/build.gradle and add this
inside the `android { ... }` block, before `buildTypes`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## Step 5 — Update package name

In android/app/build.gradle, change:
```
applicationId "com.example.truthboundary"
```
to:
```
applicationId "com.truthboundary.app"
```

This must match the packageName in cd.yml exactly.
