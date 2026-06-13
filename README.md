# FixLens AR

FixLens AR is a premium SwiftUI iOS app scaffold for AI-assisted, safety-first home maintenance guidance.

The app is built for iOS 17+ with:

- SwiftUI and MVVM screen state
- SwiftData persistence
- StoreKit 2 subscription scaffolding
- ARKit and RealityKit overlay architecture
- OCR and computer-vision placeholders
- Speech-to-text, voice response, and waveform animation scaffolding
- Native PDF export and share sheet support
- Local notification scheduling
- Mock AI enabled by default

Open `FixLensAR.xcodeproj` in Xcode and run the `FixLensAR` scheme on an iOS simulator or device.

## GitHub App Store Upload

The repository includes a manual GitHub Actions workflow, `iOS Upload Build`, that uses Xcode and Fastlane on a macOS runner to create App Store signing assets, build a signed IPA, and upload the build to App Store Connect/TestFlight.

Required repository secrets:

- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_PRIVATE_KEY`

Run the workflow from GitHub Actions and keep the marketing version at `1.0` for the current App Store version. If no build number is supplied, the workflow uses the GitHub run number so each upload is unique.

Safety posture: FixLens AR is informational only. It does not certify, replace qualified tradespeople, or instruct users to perform dangerous gas, electrical, high-voltage, or sealed-system repairs.
