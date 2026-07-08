# Deep Link (App Links & Universal Links) Configuration

This folder contains the required files to enable Deep Linking (Android App Links & iOS Universal Links) for the Mali Setu app.

## Requirements for Backend Developer

### 1. Host `.well-known` Files
Please upload the `.well-known` folder from this directory to the root of the domain (`https://malisetu.com`).
The files must be accessible at the exact following URLs:
- **Android:** `https://malisetu.com/.well-known/assetlinks.json`
- **iOS:** `https://malisetu.com/.well-known/apple-app-site-association`

**Important Note for the Files:**
- The `assetlinks.json` requires the exact SHA-256 certificate fingerprint from the Flutter team. Please replace `"YOUR_SHA256_CERTIFICATE_FINGERPRINT_HERE"` with the provided SHA-256 fingerprint.
- The `apple-app-site-association` requires the exact Apple Team ID from the iOS team. Please replace `"YOUR_TEAM_ID"` with the provided Team ID.
- Both files must be served with `Content-Type: application/json`.
- Both files must be accessible without any redirects (no 301/302).

### 2. Configure HTTPS
The domain **must** use a valid HTTPS connection (`https://malisetu.com`). App Links and Universal Links will not work on plain HTTP.

### 3. Website Route Configuration
Please configure the server to handle the following dynamic route:
`https://malisetu.com/blog/{id}`

- When a user opens this URL in a browser on a desktop or when the app is **not** installed, it should load a web page displaying the blog post.
- Alternatively, you can configure a fallback script on this page that redirects the user to the Google Play Store / Apple App Store if they are on a mobile device and the app isn't installed.

### 4. How it works (Flutter Side)
- The Flutter side has already been configured to intercept `https://malisetu.com/blog/{id}`.
- If the app is installed on the user's phone, clicking the link will automatically open the app, extract the `id`, and show the Blog Detail screen. No further code is required on the mobile end.
