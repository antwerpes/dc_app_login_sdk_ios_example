# DocCheckAppLogin

[![Version](https://img.shields.io/cocoapods/v/DocCheckAppLogin.svg?style=flat)](https://cocoapods.org/pods/DocCheckAppLoginSDK)
[![Platform](https://img.shields.io/cocoapods/p/DocCheckAppLogin.svg?style=flat)](https://cocoapods.org/pods/DocCheckAppLoginSDK)
The DocCheck App Login SDK provides you with a simple to use integration of the authentication through DocCheck. This is done by providing a ViewController which wraps the Web flow and handles callbacks for the authentication.

## Requirements

- iOS 12.0+
- Xcode 12+
- Swift 5.1+

## Installation

### CocoaPods

DocCheckAppLogin is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DocCheckAppLoginSDK'
```

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. It is in early development, but we support its use on supported platforms.

Once you have your Swift package set up, adding DocCheckAppLogin as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/antwerpes/dc_app_login_sdk_ios.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

// TODO: Outdated needs update

```swift
let docCheckAppLogin = DocCheckAppLogin.open(
    loginId: "YOUR_LOGIN_ID",
    language: "YOUR_SELECTED_LANGUAGE", // optional will default to de
    templateName: "TEMPLATE_NAME" // optional will default to s_mobile
)
// optional listener
docCheckAppLogin.loginSuccesful = {
    // do something on success like dismissing the viewcontroller
}
docCheckAppLogin.loginFailed = { error in
    // do something on failed login like showing an error message
}
docCheckAppLogin.loginCanceled = {
    // do something on user initiated cancel like showing a hint
}
docCheckAppLogin.receivedUserInformations = { userInfo in
    // get user information based on what was provided by the server
}
```

## Example

An example project with integration instructions can be found in the [Example Repository](https://github.com/antwerpes/dc_app_login_sdk_ios_example)
