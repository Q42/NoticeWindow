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

  /// pending notice
  private var pendingNoticeView: UIView?

  /// current notice view that is presented
  private var currentNoticeView: UIView?

  open func presentView(_ view: UIView, duration: TimeInterval? = 5, animated: Bool = true, completion: (() -> Void)? = nil) {

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

  private func showView(_ view: UIView, duration: TimeInterval? = 5, animated: Bool = true, dismissOnTouch: Bool = true, completion: (() -> Void)? = nil) {

    if dismissOnTouch {
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NoticeWindow.noticeTouched)))
    }

    currentNoticeView = view
    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints([
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view.superview, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view.superview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view.superview, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
      ])

    view.layoutIfNeeded()

    // If the notice has a finite duration we schedule a dismiss callback
    if let duration = duration {
      let when = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
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
      animation.isRemovedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      view.layer.add(animation, forKey: "slide in")
      CATransaction.commit()
    } else {
      completion?()
    }
  }

  open func dismissCurrentNotice(_ animated: Bool = true, completion: (() -> ())? = nil) {
    guard let noticeView = self.currentNoticeView , noticeView.layer.animation(forKey: "slide out") == nil else {
      return
    }
    dismissNotice(noticeView, animated: animated, completion: completion)
  }

  open func dismissNotice(_ noticeView: UIView, animated: Bool = true, completion: (() -> ())? = nil) {

    let complete: () -> () = { [weak self] in
      if let current = self?.currentNoticeView , current == noticeView {
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
      animation.isRemovedOnCompletion = false
      animation.fillMode = kCAFillModeForwards

      noticeView.layer.add(animation, forKey: "slide out")
      CATransaction.commit()
    } else {
      complete()
    }

  }

  func noticeTouched() {
    dismissCurrentNotice()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    if let noticeView = currentNoticeView {
      bringSubview(toFront: noticeView)
    }
  }
}

extension NoticeWindow {

  public enum Style {
    case success
    case error
  }

  public func presentNotice(_ title: String, message: String, style: Style, duration: TimeInterval = 5, animated: Bool = true, completion: (() -> ())? = nil) {

    let podBundle = Bundle(for: self.classForCoder)
    guard let bundleURL = podBundle.url(forResource: "NoticeWindow", withExtension: "bundle"), let bundle = Bundle(url: bundleURL) else {
      return print("NoticeWindow error: Could not load the NoticeWindow bundle.")
    }

    guard let view = UINib(nibName: "NoticeView", bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? NoticeView else {
      return print("NoticeWindow error: Could not instantiate the NoticeView nib.")
    }

    view.titleLabel.text = title
    view.messageLabel.text = message

    switch style {
    case .success:
      view.backgroundColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00)
    case .error:
      view.backgroundColor = UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00)
    }
    
    presentView(view, duration: duration, animated: animated, completion: completion)
  }
}
