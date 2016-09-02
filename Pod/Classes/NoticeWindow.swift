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

  public func presentView(view: UIView, duration: NSTimeInterval? = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

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

  private func showView(view: UIView, duration: NSTimeInterval? = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "noticeTouched"))

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
    if let duration = duration {
      let when = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
      dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
        // only dismiss when we it's the same notice
        if self?.currentNoticeView === view {
          self?.dismissCurrentNotice()
        }
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
    dismissNotice(noticeView, animated: animated, completion: completion)
  }

  public func dismissNotice(noticeView: UIView, animated: Bool = true, completion: (() -> ())? = nil) {

    let complete: () -> () = { [weak self] in
      if let current = self?.currentNoticeView where current == noticeView {
        current.removeFromSuperview()
        self?.currentNoticeView = nil
      }
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

extension NoticeWindow {

  public enum Style {
    case Success
    case Error
  }

  public func presentNotice(title: String, message: String, style: Style, duration: NSTimeInterval = 5, animated: Bool = true, completion: (() -> ())? = nil) {

    let podBundle = NSBundle(forClass: self.classForCoder)
    guard let bundleURL = podBundle.URLForResource("NoticeWindow", withExtension: "bundle"), bundle = NSBundle(URL: bundleURL) else {
      return print("NoticeWindow error: Could not load the NoticeWindow bundle.")
    }

    guard let view = UINib(nibName: "NoticeView", bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? NoticeView else {
      return print("NoticeWindow error: Could not instantiate the NoticeView nib.")
    }

    view.titleLabel.text = title
    view.messageLabel.text = message

    switch style {
    case .Success:
      view.backgroundColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00)
    case .Error:
      view.backgroundColor = UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00)
    }
    
    presentView(view, duration: duration, animated: animated, completion: completion)
  }
}
