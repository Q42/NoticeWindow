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

  lazy var noticeWindow: NoticeWindow = {
    return NoticeWindow(frame: UIScreen.main.bounds)
  }()

  var window: UIWindow? {
    get {
      return noticeWindow
    }
    set {
      self.window = newValue
    }
  }

}

