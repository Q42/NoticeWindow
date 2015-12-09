//
//  NoticeWindow.swift
//  Pods
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

public class NoticeWindow : UIWindow {

  /// pending notice
  private var pendingNoticeView: UIView?

  /// current notice view that is presented
  private var currentNoticeView: UIView?

  public func presentView(view: UIView, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

    if currentNoticeView != nil {
      pendingNoticeView = view

      dismissCurrentNotice(animated) {[weak self] in
        if let pendingView = self?.pendingNoticeView {
          self?.showView(pendingView, duration:  duration, animated: animated, completion: completion)
          self?.pendingNoticeView = nil
        }
      }

    } else {
      showView(view, duration: duration, animated: animated, completion: completion)
    }
  }

  private func showView(view: UIView, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

    let tagGestureRecognizer = UITapGestureRecognizer(target: self, action: "noticeTouched")
    addGestureRecognizer(tagGestureRecognizer)

    currentNoticeView = view
    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view.superview, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view.superview, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view.superview, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
    ])

    view.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback

    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
      // only dismiss when we it's the same notice
      if self?.currentNoticeView === view {
        self?.dismissCurrentNotice()
      }
    }

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock({
        completion?()
      })
      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.fromValue = -view.frame.size.height
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
    guard let noticeView = self.currentNoticeView where noticeView.layer.animationForKey("slide out") == nil else {
      return
    }

    let complete: () -> () = { [weak self] in
      self?.currentNoticeView?.removeFromSuperview()
      self?.currentNoticeView = nil
      completion?()
    }

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock(complete)
      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.toValue = -noticeView.frame.size.height
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

    if let noticeView = currentNoticeView {
      bringSubviewToFront(noticeView)
    }
  }
}
