//
//  NoticeWindow.swift
//  Pods
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

open class NoticeWindow : UIWindow {

  fileprivate var pending: Notice?
  fileprivate var current: Notice?

  open func present(notice: Notice, animated: Bool = true)
  {
    if current == nil {
      showImmediately(notice: notice, animated: animated)
    }
    else {
      pending = notice

      dismissCurrentNotice(animated) { [weak self] in
        if let pending = self?.pending {
          self?.showImmediately(notice: pending, animated: animated)
          self?.pending = nil
        }
      }

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
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
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
      notice.view.removeFromSuperview()

      if let current = self?.current, current.view === notice.view {
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
      animation.fromValue = 0
      animation.toValue = notice.position == .top ? -view.frame.size.height : +view.frame.size.height

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
      bringSubviewToFront(current.view)
    }
  }

  // This should propabily not be done this way, but instead use additionalSafeAreaInsets
  func additionalStatusBarHeight() -> CGFloat {
    if #available(iOS 11.0, *) {
      return safeAreaInsets.top == 0 ? UIApplication.shared.statusBarFrame.height : 0
    } else {
      return UIApplication.shared.statusBarFrame.height
    }
  }
}

extension NoticeWindow {

  public func present(
    view: UIView,
    duration: TimeInterval? = 5,
    position: NoticePosition = .top,
    adjustTopLayoutMarginForStatusBar: Bool = true,
    animated: Bool = true,
    completion: (() -> Void)? = nil)
  {
    if adjustTopLayoutMarginForStatusBar && position == .top {
      view.layoutMargins.top += self.additionalStatusBarHeight()
    }

    let notice = Notice(
      view: view,
      position: position,
      duration: duration,
      completion: { completion?() }
    )
    self.present(notice: notice, animated: animated)
  }

}
