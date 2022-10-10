//
//  Notice.swift
//  NoticeWindow
//
//  Created by Tom Lokhorst on 2018-01-25.
//

import Foundation
import UIKit

public enum NoticePosition {
  case top
  case bottom
}

public struct Notice {
  public var view: UIView
  public var duration: TimeInterval?
  public var position: NoticePosition
  public var dismissOnTouch: Bool
  public var tapHandler: () -> Void
  public var completion: () -> Void

  public init(
    view: UIView,
    position: NoticePosition = .top,
    duration: TimeInterval? = TimeInterval(5),
    dismissOnTouch: Bool = true,
    tapHandler: @escaping () -> Void = {},
    completion: @escaping () -> Void = {})
  {
    self.view = view
    self.position = position
    self.duration = duration
    self.dismissOnTouch = dismissOnTouch
    self.tapHandler = tapHandler
    self.completion = completion
  }
}
