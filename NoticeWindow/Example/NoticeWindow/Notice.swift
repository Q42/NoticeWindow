//
//  Notice.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

struct Notice {
  let title: String
  let message: String
  let style: Style

  enum Style {
    case Success
    case Error
  }
}

extension Notice {

  func present() {
    (UIApplication.sharedApplication().delegate as? AppDelegate)?.noticeWindow.presentNotice(self)
  }

  func dismiss() {
    (UIApplication.sharedApplication().delegate as? AppDelegate)?.noticeWindow.dismissNotice()
  }
}
