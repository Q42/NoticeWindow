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
    title: String,
    message: String,
    style: NoticeViewStyle,
    duration: TimeInterval = 5,
    adjustTopInsetForStatusBar: Bool = true,
    animated: Bool = true,
    tapHandler: (() -> ())? = nil,
    completion: (() -> ())? = nil)
  {
    guard let view = NoticeView.instantiate() else { return }

    view.titleLabel.text = title
    view.messageLabel.text = message

    view.style = style

    if adjustTopInsetForStatusBar && style.position == .top {
      view.adjustTopInset = UIApplication.shared.statusBarFrame.height
    }

    let notice = Notice(view: view, position: style.position, duration: duration, adjustTopInsetForStatusBar: adjustTopInsetForStatusBar, dismissOnTouch: true, tapHandler: { tapHandler?() }, completion: { completion?() })
    present(notice: notice, animated: animated)
  }

  public func presentNotice(
    attributedTitle: NSAttributedString,
    attributedMessage: NSAttributedString,
    style: NoticeViewStyle,
    duration: TimeInterval = 5,
    adjustTopInsetForStatusBar: Bool = true,
    animated: Bool = true,
    tapHandler: (() -> ())? = nil,
    completion: (() -> ())? = nil)
  {
    guard let view = NoticeView.instantiate() else { return }

    view.titleLabel.attributedText = attributedTitle
    view.messageLabel.attributedText = attributedMessage

    view.style = style

    if adjustTopInsetForStatusBar && style.position == .top {
      view.adjustTopInset = UIApplication.shared.statusBarFrame.height
    }

    let notice = Notice(view: view, position: style.position, duration: duration, adjustTopInsetForStatusBar: adjustTopInsetForStatusBar, dismissOnTouch: true, tapHandler: { tapHandler?() }, completion: { completion?() })
    present(notice: notice, animated: animated)
  }

}

internal extension NoticeView {
  static func instantiate() -> NoticeView? {
    guard let bundle = Bundle.noticeWindowBundle else {
      print("NoticeWindow error: Could not load the NoticeWindow bundle.")
      return nil
    }

    guard let view = UINib(nibName: "NoticeView", bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? NoticeView else {
      print("NoticeWindow error: Could not instantiate the NoticeView nib.")
      return nil
    }

    return view
  }
}

internal extension Bundle {
  static var noticeWindowBundle: Bundle? {
    let podBundle = Bundle(for: NoticeWindow.classForCoder())

    if let bundleURL = podBundle.url(forResource: "NoticeWindow", withExtension: "bundle") {
      return Bundle(url: bundleURL)
    }

    return nil
  }
}
