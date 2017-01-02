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
  case top
  case bottom
}

public struct Notice {
  public var view: UIView
  public var duration: TimeInterval?
  public var position: NoticePosition
  public var adjustTopInsetForStatusBar: Bool
  public var dismissOnTouch: Bool
  public var tapHandler: () -> Void
  public var completion: () -> Void

  public init(
    view: UIView,
    position: NoticePosition = .top,
    duration: TimeInterval? = TimeInterval(5),
    adjustTopInsetForStatusBar: Bool, // = true,
    dismissOnTouch: Bool = true,
    tapHandler: @escaping () -> Void = {},
    completion: @escaping () -> Void = {})
  {
    self.view = view
    self.position = position
    self.duration = duration
    self.dismissOnTouch = dismissOnTouch
    self.adjustTopInsetForStatusBar = adjustTopInsetForStatusBar
    self.tapHandler = tapHandler
    self.completion = completion
  }
}

open class NoticeWindow : UIWindow {

  fileprivate var pending: Notice?
  fileprivate var current: Notice?

  public override init(frame: CGRect) {
    super.init(frame: frame)

    NotificationCenter.default.addObserver(self, selector: #selector(adjustForStatusBarFrameChanges), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    NotificationCenter.default.addObserver(self, selector: #selector(adjustForStatusBarFrameChanges), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
  }

  @objc fileprivate func adjustForStatusBarFrameChanges() {

    guard
      let current = self.current, current.adjustTopInsetForStatusBar && current.position == .top
    else { return }

    // For some reason, statusBarFrame hasn't been updated yet atm, but it is in next event loop
    DispatchQueue.main.async {
      if let noticeView = current.view as? NoticeView {
        noticeView.adjustTopInset = UIApplication.shared.statusBarFrame.height
      }
      else {
        current.view.layoutMargins.top = UIApplication.shared.statusBarFrame.height
      }
    }
  }

  open func present(notice: Notice, animated: Bool = true)
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

  fileprivate func showImmediately(notice: Notice, animated: Bool) {

    current = notice
    let view = notice.view

    if notice.dismissOnTouch {
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noticeTouched)))
    }

    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: view.superview, attribute: .left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: view.superview, attribute: .right, multiplier: 1, constant: 0)
    ])

    switch notice.position {
    case .top:
      addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1, constant: 0))

    case .bottom:
      addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview, attribute: .bottom, multiplier: 1, constant: 0))
    }

    view.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback
    if let duration = notice.duration {
      let when = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
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
      animation.fromValue = notice.position == .top ? -view.frame.size.height : +view.frame.size.height
      animation.toValue = 0
      animation.isRemovedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.add(animation, forKey: "slide in")
      CATransaction.commit()
    }
  }

  open func dismissCurrentNotice(_ animated: Bool = true, dismissed: (() -> Void)? = nil) {
    if let current = self.current, current.view.layer.animation(forKey: "slide out") == nil
    {
      dismiss(notice: current, animated: animated, dismissed: dismissed)
    }
    else {
      dismissed?()
    }
  }

  open func dismiss(notice: Notice, animated: Bool = true, dismissed: (() -> Void)? = nil) {

    let complete: () -> () = { [weak self] in
      if let current = self?.current, current.view === notice.view {
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
      animation.toValue = notice.position == .top ? -view.frame.size.height : +view.frame.size.height
      animation.isRemovedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.add(animation, forKey: "slide out")
      CATransaction.commit()
    } else {
      complete()
    }

  }

  @objc fileprivate func noticeTouched() {
    current?.tapHandler()
    dismissCurrentNotice()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    if let current = self.current {
      bringSubview(toFront: current.view)
    }
  }
}

extension NoticeWindow {

  public func present(
    view: UIView,
    duration: TimeInterval? = 5,
    position: NoticePosition = .top,
    adjustTopInsetForStatusBar: Bool = true,
    animated: Bool = true,
    completion: (() -> Void)? = nil)
  {

    if adjustTopInsetForStatusBar && position == .top {
      view.layoutMargins.top = UIApplication.shared.statusBarFrame.height
    }

    let notice = Notice(view: view, position: position, duration: duration, adjustTopInsetForStatusBar: adjustTopInsetForStatusBar, completion: { completion?() })
    self.present(notice: notice, animated: animated)
  }

}
