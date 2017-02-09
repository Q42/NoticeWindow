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
  let style: Style

  enum Style {
    case Success
    case Error
  }
}

extension Notice {

  func present() {

    let view = UINib.init(nibName: "CustomNoticeView", bundle: Bundle.main)
      .instantiate(withOwner: nil, options: nil)[0] as! CustomNoticeView
    view.notice = self

    AppDelegate.noticeWindow?.present(view: view)
  }

  func dismiss() {
    AppDelegate.noticeWindow?.dismissCurrentNotice()
  }
}
