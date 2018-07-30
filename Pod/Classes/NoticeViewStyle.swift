//
//  NoticeImage.swift
//  Pods
//
//  Created by Tom Lokhorst on 2016-09-06.
//
//

import UIKit

public struct NoticeViewStyle {

  public var backgroundColor: UIColor
  public var textColor: UIColor

  public var titleNumberOfLines: Int
  public var messageNumberOfLines: Int

  public var position: NoticePosition

  public var insets: UIEdgeInsets
  public var imageSpacing: CGFloat

  public var leftImage: NoticeImage?
  public var rightImage: NoticeImage?

  public init(
    backgroundColor: UIColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
    textColor: UIColor = .white,
    titleNumberOfLines: Int = 0,
    messageNumberOfLines: Int = 0,
    position: NoticePosition = .top,
    insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
    imageSpacing: CGFloat = 10,
    leftImage: NoticeImage? = nil,
    rightImage: NoticeImage? = nil)
  {
    self.backgroundColor = backgroundColor
    self.textColor = textColor

    self.titleNumberOfLines = titleNumberOfLines
    self.messageNumberOfLines = messageNumberOfLines

    self.position = position

    self.insets = insets
    self.imageSpacing = imageSpacing

    self.leftImage = leftImage
    self.rightImage = rightImage
  }

  public static var success: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00),
      textColor: .white
    )
  }

  public static var error: NoticeViewStyle {
    return NoticeViewStyle(
      backgroundColor: UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00),
      textColor: .white
    )
  }
}


public struct NoticeImage {
  public var image: UIImage?
  public var contentMode: UIView.ContentMode
  public var tintColor: UIColor
  public var width: CGFloat

  public init(
    image: UIImage?,
    contentMode: UIView.ContentMode = .right,
    tintColor: UIColor = .white,
    width: CGFloat? = nil)
  {
    self.image = image
    self.contentMode = contentMode
    self.tintColor = tintColor
    self.width = width ?? image?.size.width ?? 0
  }

  public static var close: NoticeImage {
    let image = UIImage(
      named: "notice-view-close-icon",
      in: Bundle.noticeWindowBundle,
      compatibleWith: nil
    )

    return NoticeImage(image: image?.withRenderingMode(.alwaysTemplate))
  }

  public static var disclosure: NoticeImage {
    let image = UIImage(
      named: "notice-view-disclosure-icon",
      in: Bundle.noticeWindowBundle,
      compatibleWith: nil
    )

    return NoticeImage(image: image?.withRenderingMode(.alwaysTemplate))
  }

}
