//
//  NoticeWindow.swift
//  Pods
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

public class NoticeWindow<T> : UIWindow {

  /// set this after initializing the NoticeWindow
  public var viewForNotice: (T -> UIView)?

  /// to keep track of the actual notice, used for dismissing
  private var currentNoticeId: String?

  /// pending notice
  private var pendingNotice: T?

  /// current notice view that is presented
  private var currentNoticeView: UIView?

  /// current presented notice
  private var currentNotice: T?

  /**
   Inititalizer
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public func presentNotice(notice: T, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

    if currentNotice != nil {
      pendingNotice = notice

      dismissNotice(animated) {[weak self] in
        if let pendingNotice = self?.pendingNotice {
          self?.showNotice(pendingNotice, duration:  duration, animated: animated, completion: completion)
          self?.pendingNotice = nil
        }
      }

    } else {
      showNotice(notice, duration: duration, animated: animated, completion: completion)
    }

  }

  private func showNotice(notice: T, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

    guard let noticeView = viewForNotice?(notice) else {
      print("Error: NoticeWindow.viewForNotice should been set.")
      return
    }

    currentNoticeView = noticeView
    currentNotice = notice

    let id = NSUUID().UUIDString
    currentNoticeId = id

    addSubview(noticeView)

    noticeView.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: noticeView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: noticeView.superview, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: noticeView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: noticeView.superview, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: noticeView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: noticeView.superview, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
    ])

    noticeView.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback

    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
      // only dismiss when we haven't presented a new notice
      if self?.currentNoticeId == id {
        self?.dismissNotice()
      }
    }

    if animated {
      CATransaction.begin()
      CATransaction.setCompletionBlock({
        completion?()
      })
      let animation = CABasicAnimation(keyPath: "transform.translation.y")
      animation.duration = 0.25
      animation.fromValue = -noticeView.frame.size.height
      animation.toValue = 0
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      noticeView.layer.addAnimation(animation, forKey: "slide in")
      CATransaction.commit()
    } else {
      completion?()
    }
  }

  public func dismissNotice(animated: Bool = true, completion: (() -> ())? = nil) {
    guard let noticeView = self.currentNoticeView where noticeView.layer.animationForKey("slide out") == nil else {
      return
    }

    let complete: () -> () = {[weak self] in
      self?.currentNoticeView?.removeFromSuperview()
      self?.currentNoticeView = nil
      self?.currentNotice = nil
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

  public override func layoutSubviews() {
    super.layoutSubviews()

    if let noticeView = currentNoticeView {
      bringSubviewToFront(noticeView)
    }
  }
}
