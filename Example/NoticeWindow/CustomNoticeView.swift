//
//  NoticeView.swift
//  Grow
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

class CustomNoticeView: UIView {
  @IBOutlet weak var titleLabel: UILabel!

  var notice: Notice? {
    didSet {
      noticeDidChange()
    }
  }

  // MARK: View Lifecycle

  private func noticeDidChange() {
    guard let notice = self.notice else { return }

    switch notice.style {
    case .Success:
      backgroundColor = UIColor(red: 0.384, green: 0.483, blue: 1.000, alpha: 1.00)
    case .Error:
      backgroundColor = UIColor(red: 1.0, green: 0.641, blue: 0.218, alpha: 1.00)
    }

    titleLabel.text = notice.title
  }
}
