//
//  NoticeView.swift
//  Grow
//
//  Created by Tim van Steenis on 08/12/15.
//  Copyright © 2015 Q42. All rights reserved.
//

import Foundation
import UIKit

class NoticeView: UIView {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!

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
      backgroundColor = UIColor(red: 0.447, green: 0.659, blue: 0.376, alpha: 1.00)
    case .Error:
      backgroundColor = UIColor(red: 0.867, green: 0.125, blue: 0.125, alpha: 1.00)
    }

    titleLabel.text = notice.title
    messageLabel.text = notice.message
  }
}
