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
  private var pendingNotice: (UIView, NoticePosition)?

  /// current notice view that is presented
  private var currentNotice: (view: UIView, position: NoticePosition)?

  override public var frame: CGRect {
    didSet {

      guard
        let (currentView, _) = self.currentNotice,
        let noticeView = currentView as? NoticeView
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
      pendingNotice = (view, position)

      dismissCurrentNotice(animated) {[weak self] in
        if let (pendingView, pendingPosition) = self?.pendingNotice {
          self?.showView(pendingView, duration: duration, position: pendingPosition, animated: animated, dismissOnTouch: true, completion: completion)
          self?.pendingNotice = nil
        }
      }

    } else {
      showView(view, duration: duration, position: position, animated: animated, dismissOnTouch: true, completion: completion)
    }
  }

  private func showView(view: UIView, duration: NSTimeInterval?, position: NoticePosition, animated: Bool, dismissOnTouch: Bool, completion: (() -> Void)? = nil) {

    if dismissOnTouch {
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "noticeTouched"))
    }

    currentNotice = (view, position)
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
      CATransaction.setCompletionBlock({ completion?() })

      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.fromValue = position == .Top ? -view.frame.size.height : +view.frame.size.height
      animation.toValue = 0
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.addAnimation(animation, forKey: "slide in")
      CATransaction.commit()
    } else {
      completion?()
    }
  }

  public func dismissCurrentNotice(animated: Bool = true, completion: (() -> ())? = nil) {
    if let (noticeView, position) = self.currentNotice
      where noticeView.layer.animationForKey("slide out") == nil
    {
      dismissNotice(noticeView, position: position, animated: animated, completion: completion)
    }
  }

  public func dismissNotice(noticeView: UIView, position: NoticePosition, animated: Bool = true, completion: (() -> ())? = nil) {

    let complete: () -> () = { [weak self] in
      if let current = self?.currentNotice?.view where current == noticeView {
        current.removeFromSuperview()
        self?.currentNotice = nil
      }
      completion?()
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
      complete()
    }

  }

  func noticeTouched() {
    dismissCurrentNotice()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if let (noticeView, _) = currentNotice {
      bringSubviewToFront(noticeView)
    }
  }
}
