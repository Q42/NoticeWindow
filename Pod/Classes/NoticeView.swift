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

  @IBOutlet weak var horizontalStackView: UIStackView!

  @IBOutlet weak var leftImage: UIImageView!
  @IBOutlet weak var rightImage: UIImageView!

  @IBOutlet weak var leftImageWidth: NSLayoutConstraint!
  @IBOutlet weak var rightImageWidth: NSLayoutConstraint!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!

  var adjustTopInset: CGFloat = 0 {
    didSet {
      layoutMargins.top = style.insets.top + adjustTopInset
    }
  }

  var style: NoticeViewStyle = NoticeViewStyle() {
    didSet {
      backgroundColor = style.backgroundColor
      titleLabel.textColor = style.textColor
      messageLabel.textColor = style.textColor

      titleLabel.numberOfLines = style.titleNumberOfLines
      messageLabel.numberOfLines = style.messageNumberOfLines

      horizontalStackView.spacing = style.imageSpacing

      layoutMargins = style.insets
      layoutMargins.top = style.insets.top + adjustTopInset

      if let image = style.leftImage {
        leftImage.isHidden = false

        leftImageWidth.constant = image.width

        leftImage.image = image.image
        leftImage.tintColor = image.tintColor
        leftImage.contentMode = image.contentMode
      }
      else {
        leftImage.isHidden = true
      }

      if let image = style.rightImage {
        rightImage.isHidden = false

        rightImageWidth.constant = image.width

        rightImage.image = image.image
        rightImage.tintColor = image.tintColor
        rightImage.contentMode = image.contentMode
      }
      else {
        rightImage.isHidden = true
      }
    }
  }
}
