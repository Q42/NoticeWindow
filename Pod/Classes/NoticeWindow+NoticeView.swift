//
//  NoticeWindow+NoticeView.swift
//  Pods
//
//  Created by Tom Lokhorst on 2016-09-06.
//
//

import UIKit

extension NoticeWindow {

  public func presentNotice(
    title title: String,
    message: String,
    style: NoticeViewStyle,
    duration: NSTimeInterval = 5,
    animated: Bool = true,
    completion: (() -> ())? = nil)
  {
    guard let view = NoticeView.instantiate() else { return }

    view.titleLabel.text = title
    view.messageLabel.text = message

    view.style = style

    presentView(view, duration: duration, position: style.position, animated: animated, completion: completion)
  }

  public func presentNotice(
    attributedTitle attributedTitle: NSAttributedString,
    attributedMessage: NSAttributedString,
    style: NoticeViewStyle,
    duration: NSTimeInterval = 5,
    animated: Bool = true,
    completion: (() -> ())? = nil)
  {
    guard let view = NoticeView.instantiate() else { return }

    view.titleLabel.attributedText = attributedTitle
    view.messageLabel.attributedText = attributedMessage

    view.style = style

    presentView(view, duration: duration, position: style.position, animated: animated, completion: completion)
  }

}

internal extension NoticeView {
  static func instantiate() -> NoticeView? {
    guard let bundle = NSBundle.noticeWindowBundle else {
      print("NoticeWindow error: Could not load the NoticeWindow bundle.")
      return nil
    }

    guard let view = UINib(nibName: "NoticeView", bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? NoticeView else {
      print("NoticeWindow error: Could not instantiate the NoticeView nib.")
      return nil
    }

    return view
  }
}

internal extension NSBundle {
  static var noticeWindowBundle: NSBundle? {
    let podBundle = NSBundle(forClass: NoticeWindow.classForCoder())

    if let bundleURL = podBundle.URLForResource("NoticeWindow", withExtension: "bundle") {
      return NSBundle(URL: bundleURL)
    }

    return nil
  }
}
