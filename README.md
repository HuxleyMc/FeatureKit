
# FeatureKit

FeatureKit is a Swift package designed to facilitate the use of feature flags in your projects.

## About

Feature flags (also known as feature toggles) allow you to turn features of your application on or off, independent of deployment. This can be useful for many reasons such as testing, phased rollouts, and A/B testing.

## Installation

To include FeatureKit in your project, you can add the package via Swift Package Manager. 

```swift
dependencies: [
    .package(url: "https://github.com/HuxleyMc/FeatureKit", from: "1.0.0")
]
```

## Usage

To use FeatureKit, you can import the package and create feature flags as needed. Here is a simple example:

```swift
import FeatureKit

let defaultStore: FeatureStore = .init(
    order: 1,
    name: "Default",
    flags: [
        "new-login-screen": true,
        "new-sign-up-screen": "2.3.0"
    ]
)

// Bundle Version is your apps version
let featuresFlags = FeatureKit(bundleVersion: "2.5.0")

// Add your featureStore to the FeatureKit
features.addFeatureFlags(defaultStore)

let isNewLoginEnabled = features.feature("new-login-screen")

print("Enabled \(isNewLoginEnabled)")
// prints "Enabled true"
```

## Contributing

We welcome contributions! If you have a bug to report, feel free to open an issue. If you wish to contribute code, please open a pull request.

<!-- ## License

FeatureKit is released under the MIT License. See LICENSE for details. -->
