//
//  NoticeWindow.swift
//  Pods
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

public enum NoticePosition {
  case Top
  case Bottom
}

public struct Notice {
  public var view: UIView
  public var duration: NSTimeInterval?
  public var position: NoticePosition
  public var dismissOnTouch: Bool
  public var tapHandler: () -> Void
  public var completion: () -> Void

  public init(
    view: UIView,
    position: NoticePosition = .Top,
    duration: NSTimeInterval? = NSTimeInterval(5),
    dismissOnTouch: Bool = true,
    tapHandler: () -> Void = {},
    completion: () -> Void = {})
  {
    self.view = view
    self.position = position
    self.duration = duration
    self.dismissOnTouch = dismissOnTouch
    self.tapHandler = tapHandler
    self.completion = completion
  }
}

public class NoticeWindow : UIWindow {

  private var pending: Notice?
  private var current: Notice?

  override public var frame: CGRect {
    didSet {

      guard
        let current = self.current,
        let noticeView = current.view as? NoticeView
        where noticeView.style.adjustTopInsetForStatusBar
      else { return }

      // For some reason, statusBarFrame hasn't been updated yet atm, but it is in next event loop
      dispatch_async(dispatch_get_main_queue()) {

        // Trigger update of style top inset
        let style = noticeView.style
        noticeView.style = style
      }
    }
  }

  public func present(notice notice: Notice, animated: Bool = true)
  {
    if current != nil {
      pending = notice

      dismissCurrentNotice(animated) { [weak self] in
        if let pending = self?.pending {
          self?.showImmediately(notice: pending, animated: animated)
          self?.pending = nil
        }
      }

    }
    else {
      showImmediately(notice: notice, animated: animated)
    }
  }

  private func showImmediately(notice notice: Notice, animated: Bool) {

    current = notice
    let view = notice.view

    if notice.dismissOnTouch {
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noticeTouched)))
    }

    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: view.superview, attribute: .Left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: view.superview, attribute: .Right, multiplier: 1, constant: 0)
    ])

    switch notice.position {
    case .Top:
      addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1, constant: 0))

    case .Bottom:
      addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Bottom, multiplier: 1, constant: 0))
    }

    view.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback
    if let duration = notice.duration {
      let when = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
      dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
        // only dismiss when we it's the same notice
        if self?.current?.view === view {
          self?.dismissCurrentNotice()
        }
      }
    }

    if animated {
      CATransaction.begin()

      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.fromValue = notice.position == .Top ? -view.frame.size.height : +view.frame.size.height
      animation.toValue = 0
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.addAnimation(animation, forKey: "slide in")
      CATransaction.commit()
    }
  }

  public func dismissCurrentNotice(animated: Bool = true, dismissed: (() -> Void)? = nil) {
    if let current = self.current
      where current.view.layer.animationForKey("slide out") == nil
    {
      dismiss(notice: current, animated: animated, dismissed: dismissed)
    }
  }

  public func dismiss(notice notice: Notice, animated: Bool = true, dismissed: (() -> Void)? = nil) {

    let complete: () -> () = { [weak self] in
      if let current = self?.current where current.view === notice.view {
        current.view.removeFromSuperview()
        self?.current = nil
        current.completion()
      }

      dismissed?()
    }

    let view = notice.view

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock(complete)
      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.toValue = notice.position == .Top ? -view.frame.size.height : +view.frame.size.height
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.addAnimation(animation, forKey: "slide out")
      CATransaction.commit()
    } else {
      complete()
    }

  }

  @objc private func noticeTouched() {
    current?.tapHandler()
    dismissCurrentNotice()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if let current = self.current {
      bringSubviewToFront(current.view)
    }
  }
}

extension NoticeWindow {

  public func present(view view: UIView, duration: NSTimeInterval? = 5, position: NoticePosition = .Top, animated: Bool = true, completion: (() -> Void)? = nil) {
    let notice = Notice(view: view, duration: duration, position: position, completion: { completion?() })
    self.present(notice: notice, animated: animated)
  }

}
