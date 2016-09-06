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

  @IBOutlet weak var horizontalStackView: UIStackView!

  @IBOutlet weak var leftImage: UIImageView!
  @IBOutlet weak var rightImage: UIImageView!

  @IBOutlet weak var leftImageWidth: NSLayoutConstraint!
  @IBOutlet weak var rightImageWidth: NSLayoutConstraint!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!

  var style: NoticeViewStyle = NoticeViewStyle() {
    didSet {
      backgroundColor = style.backgroundColor
      titleLabel.textColor = style.textColor
      messageLabel.textColor = style.textColor

      horizontalStackView.spacing = style.imageSpacing

      top.constant = style.insets.top
      leading.constant = style.insets.left
      bottom.constant = style.insets.bottom
      trailing.constant = style.insets.right

      if let image = style.leftImage {
        leftImage.hidden = false

        leftImageWidth.constant = image.width

        leftImage.image = image.image
        leftImage.tintColor = image.tintColor
        leftImage.contentMode = image.contentMode
      }
      else {
        leftImage.hidden = true
      }

      if let image = style.rightImage {
        rightImage.hidden = false

        rightImageWidth.constant = image.width

        rightImage.image = image.image
        rightImage.tintColor = image.tintColor
        rightImage.contentMode = image.contentMode
      }
      else {
        rightImage.hidden = true
      }
    }
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

    view.style = style

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
