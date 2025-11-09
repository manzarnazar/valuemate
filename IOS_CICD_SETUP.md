# iOS CI/CD Setup Guide for Valuemate

This guide will help you set up automated deployment to the App Store using GitHub Actions and Fastlane.

## 📋 Prerequisites

Before setting up CI/CD, ensure you have:

1. **Apple Developer Account** (paid membership required)
2. **App Store Connect Access** with necessary permissions
3. **GitHub Repository** with admin access
4. **Xcode** installed locally (for initial setup)
5. **Fastlane** installed locally

## 🚀 Initial Setup

### 1. Install Fastlane Locally

```bash
cd ios
# Configure bundler to install gems locally (avoids permission issues)
bundle config set --local path 'vendor/bundle'
bundle install
```

> **Note:** If you encounter permission errors, the above configuration installs gems in the project directory instead of system-wide.

### 2. Set Up Fastlane Match (Code Signing)

Fastlane Match manages your certificates and provisioning profiles in a separate private Git repository.

#### Create a Private Git Repository

Create a new **private** repository on GitHub (e.g., `valuemate-certificates`) to store your certificates and provisioning profiles.

#### Initialize Match

```bash
cd ios
bundle exec fastlane match init
```

> **Note:** Since fastlane is installed locally via Bundler, you must use `bundle exec` before all fastlane commands.

When prompted:
- Choose `git` as storage mode
- Enter your certificates repository URL: `https://github.com/YOUR_USERNAME/valuemate-certificates`

#### Generate Certificates

```bash
# Generate App Store certificates and profiles
bundle exec fastlane match appstore

# Generate Development certificates and profiles (optional, for local development)
bundle exec fastlane match development
```

You'll be prompted to:
- Enter your Apple ID
- Enter a passphrase (save this - you'll need it for CI/CD)
- Confirm app bundle ID: `com.valuema8`

### 3. Create App Store Connect API Key

This is the **recommended** approach for CI/CD:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Keys** (under Integrations)
3. Click **Generate API Key** or the **+** button
4. Give it a name (e.g., "GitHub Actions CI/CD")
5. Select **App Manager** or **Admin** access
6. Download the `.p8` file (you can only download it once!)
7. Note the **Key ID** and **Issuer ID**

### 4. Set Up GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

#### Required Secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Your API Key ID | From step 3 above |
| `APP_STORE_CONNECT_ISSUER_ID` | Your Issuer ID | From step 3 above |
| `APP_STORE_CONNECT_KEY` | Contents of .p8 file | Open the .p8 file in a text editor and copy the entire content |
| `MATCH_PASSWORD` | Passphrase for Match | The passphrase you set when running `fastlane match` |
| `MATCH_GIT_URL` | Certificates repo URL | `https://github.com/manzarnazar/valuemate-certificates` |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Git credentials for Match repo | See below for instructions |
| `FASTLANE_USER` | Your Apple ID email | Your Apple Developer account email |
| `MATCH_KEYCHAIN_PASSWORD` | Password used by CI to create/use a temporary keychain | Set any strong value; add it as a GitHub Secret |

#### Alternative Authentication (if not using App Store Connect API):

| Secret Name | Description |
|-------------|-------------|
| `FASTLANE_PASSWORD` | Your Apple ID password |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | App-specific password |

#### How to Generate MATCH_GIT_BASIC_AUTHORIZATION:

The Match repository needs authentication to clone certificates. Generate a Personal Access Token:

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Give it a name (e.g., "Fastlane Match")
4. Select scopes: `repo` (all sub-options)
5. Generate and copy the token
6. Create the authorization string:
   ```bash
   echo -n "YOUR_GITHUB_USERNAME:YOUR_GITHUB_TOKEN" | base64
   ```
7. Use the output as the value for `MATCH_GIT_BASIC_AUTHORIZATION`

#### Optional Secrets:

| Secret Name | Description |
|-------------|-------------|
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications |
| `ITC_TEAM_ID` | App Store Connect Team ID (if multiple teams) |

## 🔄 How to Use the CI/CD Pipeline

### Automatic Deployment to TestFlight

Push to the `main` branch:

```bash
git push origin main
```

This will automatically:
1. Run Flutter tests
2. Build the iOS app
3. Upload to TestFlight

### Manual Deployment

Trigger manually from GitHub Actions:

1. Go to **Actions** tab in your repository
2. Select **iOS Deploy to App Store**
3. Click **Run workflow**
4. Choose release type:
   - `testflight` - Deploy to TestFlight only
   - `production` - Submit to App Store

### Deploy with Git Tags

Create and push a version tag for production releases:

```bash
git tag v3.0.6
git push origin v3.0.6
```

Tags starting with `v` will automatically deploy to production.

## 📱 Fastlane Commands (Local Use)

> **Important:** All fastlane commands must be prefixed with `bundle exec` since fastlane is installed locally via Bundler.

### Build the App

```bash
cd ios
bundle exec fastlane ios build
```

### Deploy to TestFlight

```bash
cd ios
bundle exec fastlane ios beta
```

### Deploy to App Store

```bash
cd ios
bundle exec fastlane ios release
```

### Update Certificates

```bash
cd ios
bundle exec fastlane ios sync_signing
```

### Bump Version Numbers

```bash
# Increment build number
cd ios
bundle exec fastlane ios bump_build

# Increment version (patch: 3.0.6 → 3.0.7)
bundle exec fastlane ios bump_version type:patch

# Increment version (minor: 3.0.6 → 3.1.0)
bundle exec fastlane ios bump_version type:minor

# Increment version (major: 3.0.6 → 4.0.0)
bundle exec fastlane ios bump_version type:major
```

## 🔍 Troubleshooting

### Build Fails with Code Signing Error

1. Verify all GitHub secrets are correctly set
2. Run `bundle exec fastlane match appstore` locally to ensure certificates are valid
3. Check that your Apple Developer account membership is active

### Match Repository Access Denied

1. Verify `MATCH_GIT_BASIC_AUTHORIZATION` is correctly encoded
2. Ensure the Personal Access Token has `repo` permissions
3. Check that the Match repository URL in `MATCH_GIT_URL` is correct

### TestFlight Upload Fails

1. Ensure your Apple ID has App Manager or Admin role in App Store Connect
2. Verify the app exists in App Store Connect
3. Check that the bundle identifier matches: `com.valuema8`

### Two-Factor Authentication Issues

Use App Store Connect API Key instead of username/password authentication. This is the modern, recommended approach that bypasses 2FA issues.

## 📝 Version Management

The app version is managed in `pubspec.yaml`:

```yaml
version: 3.0.6+6
```

- `3.0.6` = Version Name (CFBundleShortVersionString)
- `6` = Build Number (CFBundleVersion)

Update these values before creating a release. The build number must be incremented for each App Store submission.

## 🔐 Security Best Practices

1. **Never commit secrets** to your repository
2. Keep your Match repository **private**
3. Rotate Personal Access Tokens regularly
4. Use App Store Connect API Keys instead of passwords
5. Limit API key permissions to what's necessary
6. Review GitHub Actions logs for sensitive information before sharing

## 📦 What Each File Does

- **`.github/workflows/ios-deploy.yml`** - GitHub Actions workflow definition
- **`ios/fastlane/Fastfile`** - Fastlane automation scripts
- **`ios/fastlane/Appfile`** - App and Apple ID configuration
- **`ios/fastlane/Matchfile`** - Certificate management configuration
- **`ios/Gemfile`** - Ruby dependencies

## 🎯 Next Steps

1. Complete the initial setup steps above
2. Test the workflow by pushing to `main` branch
3. Monitor the GitHub Actions tab for build progress
4. Check TestFlight for your uploaded build
5. Distribute to testers or submit for App Store review

## 📞 Support

If you encounter issues:
- Check GitHub Actions logs for detailed error messages
- Review Fastlane documentation: https://docs.fastlane.tools/
- Verify Apple Developer account status
- Ensure all certificates are valid and not expired

---

**Note:** The first pipeline run may take 15-20 minutes. Subsequent runs will be faster due to caching.
