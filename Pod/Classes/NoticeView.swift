//
//  NoticeView.swift
//  Pods
//
//  Created by Tim van Steenis on 09/12/15.
//
//

import Foundation
import UIKit

class NoticeView: UIView {

  @IBOutlet weak var top: NSLayoutConstraint!
  @IBOutlet weak var leading: NSLayoutConstraint!
  @IBOutlet weak var bottom: NSLayoutConstraint!
  @IBOutlet weak var trailing: NSLayoutConstraint!

  @IBOutlet weak var leftImage: UIImageView!
  @IBOutlet weak var rightImage: UIImageView!

  @IBOutlet weak var leftImageWidth: NSLayoutConstraint!
  @IBOutlet weak var rightImageWidth: NSLayoutConstraint!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
}

public struct NoticeViewStyle {

  public var backgroundColor: UIColor
  public var textColor: UIColor
  public var position: NoticePosition
  public var insets: UIEdgeInsets

  public var adjustTopInsetForStatusBar: Bool

  public init(
    backgroundColor: UIColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
    textColor: UIColor = .whiteColor(),
    position: NoticePosition = .Bottom,
    insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
    adjustTopInsetForStatusBar: Bool = true
  )
  {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    self.position = position
    self.insets = insets
    self.adjustTopInsetForStatusBar = adjustTopInsetForStatusBar
  }

  public static var success: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
      textColor: .whiteColor()
    )
  }

  public static var error: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00),
      textColor: .whiteColor()
    )
  }
}

extension NoticeWindow {

  public func presentNotice(
    title title: String,
    message: String,
    style: NoticeViewStyle,
    duration: NSTimeInterval = 5,
    animated: Bool = true,
    completion: (() -> ())? = nil)
  {
    guard let bundle = NSBundle.noticeWindowBundle else {
      return print("NoticeWindow error: Could not load the NoticeWindow bundle.")
    }

    guard let view = UINib(nibName: "NoticeView", bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? NoticeView else {
      return print("NoticeWindow error: Could not instantiate the NoticeView nib.")
    }

    view.titleLabel.text = title
    view.messageLabel.text = message

    view.backgroundColor = style.backgroundColor
    view.titleLabel.textColor = style.textColor
    view.messageLabel.textColor = style.textColor

    view.leftImage.hidden = true
    view.rightImage.image = UIImage(named: "notice-view-disclosure-icon", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
    view.rightImage.contentMode = .Right
    view.rightImage.tintColor = UIColor.whiteColor()


    let diff: CGFloat = style.position == .Top && style.adjustTopInsetForStatusBar ? 20 : 0

    view.top.constant = style.insets.top + diff
    view.leading.constant = style.insets.left
    view.bottom.constant = style.insets.bottom
    view.trailing.constant = style.insets.right

    presentView(view, duration: duration, position: style.position, animated: animated, completion: completion)
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
