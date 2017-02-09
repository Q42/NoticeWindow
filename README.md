<img src="https://cloud.githubusercontent.com/assets/75655/22114032/7539aec8-de68-11e6-8c18-b74fd0c046b9.png" width="185" alt="NoticeWindow"> [![CI Status](http://img.shields.io/travis/Tim van Steenis/NoticeWindow.svg?style=flat)](https://travis-ci.org/Tim van Steenis/NoticeWindow)
[![Version](https://img.shields.io/cocoapods/v/NoticeWindow.svg?style=flat)](http://cocoapods.org/pods/NoticeWindow)
[![License](https://img.shields.io/cocoapods/l/NoticeWindow.svg?style=flat)](http://cocoapods.org/pods/NoticeWindow)
[![Platform](https://img.shields.io/cocoapods/p/NoticeWindow.svg?style=flat)](http://cocoapods.org/pods/NoticeWindow)

<hr>

## Example

First, set the NoticeWindow to be the window of the AppDelegate:

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow? = NoticeWindow(frame: UIScreen.main.bounds)

  // Helper property to quickly access the NoticeWindow
  static var noticeWindow: NoticeWindow? {
    return (UIApplication.shared.delegate as? AppDelegate)?.window as? NoticeWindow
  }

}
```

Second, present a Notice using the static var on AppDelegate:

```swift
AppDelegate.noticeWindow?.presentNotice(title: "Oops", message: "An error has occurred", style: .error)
```

The default error style can be customized by changing properties on the NoticeViewStyle struct. For example:

```swift
var style = NoticeViewStyle.error
style.backgroundColor = UIColor(red: 0.839, green: 0.345, blue: 0.227, alpha: 1.00)
style.rightImage = .close

AppDelegate.noticeWindow?.presentNotice(title: "Oops", message: "An error has occurred", style: style)
```

For more detailed examples, including how to use a custom view, see the Example project in this repository.

## Installation

NoticeWindow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NoticeWindow"
```

Releases
--------

 - 0.5.2 - 2017-02-09 - Fix AutoLayout warnings
 - **0.5.1** - 2017-01-19 - CocoaPods release
 - 0.5.0 - 2017-01-02 - Swift 3 support
 - 0.4.0 - 2016-11-06 - Support more styling
 - **0.1.1** - 2015-12-08 - Initial public release
 - 0.0.0 - 2015-04-28 - Initial private version for project at [Q42](http://q42.com)


## License

NoticeWindow is available under the MIT license. See the LICENSE file for more info.
