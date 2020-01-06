<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
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

## 🌟 Features
- [x] Easy to integrate
- [x] PCI compliance (We do not save anything)

## 🐒 How to use

### 1 - Import into project
```swift
import MLCardForm
```

### 2 - Create an instance of MLCardFormBuilder with your `PublicKey` or `PrivateKey` and your `siteId
```swift
let builder = MLCardFormBuilder(publicKey: yourPublicKey, siteId: yourSiteId, lifeCycleDelegate: self)
```

### 3 - Implement `MLCardFormLifeCycleDelegate` to get notified about MLCardForm events.
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

### 4 - Use the builder as parameter to get an instance of MLCardFormViewController.
```swift
let cardFormVC = MLCardForm(builder: builder).setupController()
```

### 5 - Push the instance of MLCardFormViewController to your stack.
```swift
navigationController?.pushViewController(cardFormVC, animated: true)
```

## 💡 Advanced features
### 📈 Tracking
We provide `MLCardFormTrackerDelegate` protocol to notify each tracking event. You can subscribe to this protocol using MLCardFormConfiguratorManager
```swift
@objc public protocol MLCardFormTrackerDelegate: NSObjectProtocol {
    func trackScreen(screenName: String, extraParams: [String: Any]?)
    func trackEvent(screenName: String?, extraParams: [String: Any]?)
}
```

### 😉 Next steps
* [ ] Bitrise integration
* [ ] UI XCtest
* [ ] SwiftLint


### 🔮 Project Example
This project include an example project using `MLCardForm`.
Enter to path: `card-form-ios/Example` and run pod install command. After that, you can open `Example_CardForm.xcworkspace`


### 📋 Supported OS & SDK Versions
* iOS 10.0+
* Swift 5
* xCode 10+
* @Objc full compatibility

## ❤️ Feedback
This is an open source project, so feel free to contribute. How? -> Fork this project and propose your own fixes, suggestions and open a pull request with the changes.

## 👨🏻‍💻 Authors
* Esteban Boffa
* Eric Ertl
* Juan Sanzone

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
