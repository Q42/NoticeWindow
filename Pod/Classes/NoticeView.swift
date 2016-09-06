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

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
}

public struct NoticeViewStyle {

  public var backgroundColor: UIColor
  public var textColor: UIColor
  public var position: NoticePosition

  public init(
    backgroundColor: UIColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
    textColor: UIColor = .whiteColor(),
    position: NoticePosition = .Top
    )
  {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    self.position = position
  }

  public static var success: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
      textColor: UIColor.whiteColor()
    )
  }

  public static var error: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00),
      textColor: UIColor.whiteColor()
    )
  }
}

extension NoticeWindow {

  public func presentNotice(title: String, message: String, style: NoticeViewStyle, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> ())? = nil) {

    let podBundle = NSBundle(forClass: NoticeWindow.classForCoder())
    guard let bundleURL = podBundle.URLForResource("NoticeWindow", withExtension: "bundle"), bundle = NSBundle(URL: bundleURL) else {
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

    presentView(view, duration: duration, position: style.position, animated: animated, completion: completion)
  }
}
