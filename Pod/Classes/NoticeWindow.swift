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

public class NoticeWindow : UIWindow {

  /// pending notice
  private var pendingNotice: (UIView, NoticePosition, () -> Void)?

  /// current notice view that is presented
  private var currentNotice: (view: UIView, position: NoticePosition, completion: () -> Void)?

  override public var frame: CGRect {
    didSet {

      guard
        let current = self.currentNotice,
        let noticeView = current.view as? NoticeView
        where noticeView.style.adjustTopInsetForStatusBar
      else { return }

      // For some reason, statusBarFrame hasn't been updated yet atm, but it is in next event loop
      dispatch_async(dispatch_get_main_queue()) {

        // Trigger update of style
        let style = noticeView.style
        noticeView.style = style
      }
    }
  }

  public func presentView(view: UIView, duration: NSTimeInterval? = 5, position: NoticePosition = .Top, animated: Bool = true, completion: (() -> Void)? = nil) {

    if currentNotice != nil {
      pendingNotice = (view, position, { completion?() })

      dismissCurrentNotice(animated) { [weak self] in
        if let (pendingView, pendingPosition, pendingCompletion) = self?.pendingNotice {
          self?.showView(
            view: pendingView,
            duration: duration,
            position: pendingPosition,
            animated: animated,
            dismissOnTouch: true,
            presented: { },
            completion: pendingCompletion)
          self?.pendingNotice = nil
        }
      }

    }
    else {

      showView(
        view: view,
        duration: duration,
        position: position,
        animated: animated,
        dismissOnTouch: true,
        presented: { },
        completion: { completion?() })
    }
  }

  private func showView(view view: UIView, duration: NSTimeInterval?, position: NoticePosition, animated: Bool, dismissOnTouch: Bool, presented: () -> Void, completion: () -> Void) {

    if dismissOnTouch {
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noticeTouched)))
    }

    currentNotice = (view, position, completion)
    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: view.superview, attribute: .Left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: view.superview, attribute: .Right, multiplier: 1, constant: 0)
    ])

    switch position {
    case .Top:
      addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1, constant: 0))

    case .Bottom:
      addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Bottom, multiplier: 1, constant: 0))
    }

    view.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback
    if let duration = duration {
      let when = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
      dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
        // only dismiss when we it's the same notice
        if self?.currentNotice?.view === view {
          self?.dismissCurrentNotice()
        }
      }
    }

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock(presented)

      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.fromValue = position == .Top ? -view.frame.size.height : +view.frame.size.height
      animation.toValue = 0
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.addAnimation(animation, forKey: "slide in")
      CATransaction.commit()
    } else {
      presented()
    }
  }

  public func dismissCurrentNotice(animated: Bool = true, dismissed: (() -> Void)? = nil) {
    if let (noticeView, position, _) = self.currentNotice
      where noticeView.layer.animationForKey("slide out") == nil
    {
      dismissNotice(noticeView, position: position, animated: animated, dismissed: { dismissed?() })
    }
  }

  public func dismissNotice(noticeView: UIView, position: NoticePosition, animated: Bool = true, dismissed: () -> Void) {

    let complete: () -> () = { [weak self] in
      if let (currentView, _, completion) = self?.currentNotice where currentView == noticeView {
        currentView.removeFromSuperview()
        self?.currentNotice = nil
        completion()
      }

      dismissed()
    }

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock(complete)
      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.toValue = position == .Top ? -noticeView.frame.size.height : +noticeView.frame.size.height
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      noticeView.layer.addAnimation(animation, forKey: "slide out")
      CATransaction.commit()
    } else {
      dismissed()
    }

  }

  @objc private func noticeTouched() {
    dismissCurrentNotice()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if let (noticeView, _, _) = currentNotice {
      bringSubviewToFront(noticeView)
    }
  }
}
