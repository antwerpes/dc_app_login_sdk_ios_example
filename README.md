DocCheck App Login SDK Example iOS
==============================

This example app will demonstrate the usage of the [DocCheck App Login SDK](https://github.com/antwerpes/dc_app_login_sdk_ios) for iOS.

Configuration
------------

#### LoginId

Change the login Id either within the `ExternalModel.swift`

```swift
class ExternalModel: ObservableObject {
    // configuration for LoginView - add ur config
    @Published var loginId: String = "2000000016697" // login id in format like this 2000000004586
    @Published var language: String = "de" // language
    @Published var templateName: String = "s_mobile" // template_name
    
    //...
}

```

or within the app in the displayed input field.

#### Bundle Identifier

Make sure that the app bundle identifier matches the bundle identifier used during configuration of ur credentials for the DocCheck App Login. This can be changed in the `App Login Test.xcodeproj` on the build target for the App under **General**.

#### Signing

To be able to run this app either on a simulator or a device u need to make sure u setup a valid signing configuration for the build target under **Signing & Capabilities**.
