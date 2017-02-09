//
//  AppDelegate.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 12/08/2015.
//  Copyright (c) 2015 Tim van Steenis. All rights reserved.
//

import UIKit
import NoticeWindow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  static var noticeWindow: NoticeWindow? {
    return (UIApplication.shared.delegate as? AppDelegate)?.window as? NoticeWindow
  }

  var window: UIWindow? = NoticeWindow(frame: UIScreen.main.bounds)

}

