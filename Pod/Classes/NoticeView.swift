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

  var style: NoticeViewStyle = NoticeViewStyle() {
    didSet {
      backgroundColor = style.backgroundColor
      titleLabel.textColor = style.textColor
      messageLabel.textColor = style.textColor

      titleLabel.numberOfLines = style.titleNumberOfLines
      messageLabel.numberOfLines = style.messageNumberOfLines

      horizontalStackView.spacing = style.imageSpacing

      layoutMargins = style.insets

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

  public override init(frame: CGRect) {
    super.init(frame: frame)

    NotificationCenter.default
      .addObserver(self, selector: #selector(adjustForStatusBarFrameChanges), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    NotificationCenter.default
      .addObserver(self, selector: #selector(adjustForStatusBarFrameChanges), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
  }

  @objc fileprivate func adjustForStatusBarFrameChanges() {
    guard style.position == .top else { return }

    // For some reason, statusBarFrame hasn't been updated yet when rotating, but it is in next event loop
    DispatchQueue.main.async {
      self.updateLayoutMarginsWithStatusBarHeight()
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    updateLayoutMarginsWithStatusBarHeight()
  }

  private func updateLayoutMarginsWithStatusBarHeight() {
    guard style.position == .top else { return }

    let additionalHeight = (window as? NoticeWindow)?.additionalStatusBarHeight() ?? 0
    layoutMargins.top = style.insets.top + additionalHeight
  }
}
