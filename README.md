<p align="center">
    <img src="https://img.shields.io/badge/Swift-4.2-orange.svg" />
    <a href="https://cocoapods.org/pods/">
        <img src="https://img.shields.io/cocoapods/v/MLCardForm.svg" alt="CocoaPods" />
    </a>
    <a href="https://cocoapods.org/pods/MLCardForm">
        <img src="https://img.shields.io/cocoapods/dt/MLCardForm.svg?style=flat" alt="CocoaPods downloads" />
    </a>
</p>

## 📲 How to Install

#### Using [CocoaPods](https://cocoapods.org)

Edit your `Podfile` and specify the dependency:

```ruby
pod 'MLCardForm'
```

#### Using [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add `MLCardForm` as a dependency. Adding the following line in `dependencies`value of your `Package.swift`.

```swift
  dependencies: [
    .package(url: "https://github.com/mercadolibre/card-form-ios.git", from: "1.0")
  ]
```

## 🌟 Features
- [x] Easy to integrate
- [x] PCI compliance (We do not save anything)

## 🐒 How to use

### 1 - Import into project
```swift
import MLCardForm
```

### 2 - Implement `MLCardFormLifeCycleDelegate` to get notified about MLCardForm events.
```swift
extension YourViewController: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        // The card has been added. You can pop the `MLCardFormViewController` here.
    }

    func didFailAddCard() {
        // There was an error adding the card.
    }
}
```

### 3 - Create an instance of MLCardFormBuilder with your `PublicKey` or `PrivateKey` and your `siteId
```swift
let builder = MLCardFormBuilder(publicKey: yourPublicKey, siteId: yourSiteId, lifeCycleDelegate: self)
```

### 3 - Use the builder as parameter to get an instance of MLCardFormViewController.
```swift
let cardFormVC = MLCardForm(builder: builder).setupController()
```

### 4 - Push the instance of MLCardFormViewController to your stack.
```swift
navigationController?.pushViewController(cardFormVC, animated: true)
```

## 💡 Advanced features

### 📈 Tracking
We provide `MLCardFormTrackerDelegate` protocol to notify each tracking event. You can subscribe to this protocol using MLCardFormBuilder
```swift
@objc public protocol MLCardFormTrackerDelegate: NSObjectProtocol {
    func trackScreen(screenName: String, extraParams: [String: Any]?)
    func trackEvent(screenName: String?, action: String, result: String?, extraParams: [String: Any]?)
}
```

### 🎨 CardUI protocol
Using `CardUI` protocol to customize: position of security code, card background, font color, place holders, etc.

```swift
@objc public protocol CardUI {
    var cardPattern: [Int] { get }
    var placeholderName: String { get }
    var placeholderExpiration: String { get }
    var cardFontColor: UIColor { get }
    var cardBackgroundColor: UIColor { get }
    var securityCodeLocation: MLCardSecurityCodeLocation { get }
    var defaultUI: Bool { get }
    var securityCodePattern: Int { get }

    @objc optional func set(bank: UIImageView)
    @objc optional func set(logo: UIImageView)
    @objc optional var fontType: String { get }
    @objc optional var bankImage: UIImage? { get }
    @objc optional var cardLogoImage: UIImage? { get }
    @objc optional var ownOverlayImage: UIImage? { get }
}
```

### 😉 Next steps
* [x] Bitrise for releases
* [x] Codebeat integration
* [x] Shine card effect with MotionEffect 🔥🔥
* [ ] SwiftLint
* [ ] Migration to Swift 5
* [ ] Native support to display card in disabled mode (card disabled)
* [ ] Version 2.0 SwiftUI compatible 😈


### 🔮 Project Example
This project include an example project using `MLCardForm` and another target with `xCTests` test cases.
Enter to path: `meli-card-drawer-ios/Example_MeliCardDrawer` and run pod install command. After that, you can open `Example_MeliCardDrawer.xcworkspace`


### 🕵️‍♂️ Test cases
![TestCases](https://i.ibb.co/3c0h1wF/Tests.png)

### 📋 Supported OS & SDK Versions
* iOS 9.0+
* Swift 4.2
* xCode 9.2+
* @Objc full compatibility

## ❤️ Feedback
This is an open source project, so feel free to contribute. How? -> Fork this project and propose your own fixes, suggestions and open a pull request with the changes.

## 👨🏻‍💻 Author
Juan Sanzone / @juansanzone

## 👮🏻 License

```
Copyright 2019 Mercadolibre Developers

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
