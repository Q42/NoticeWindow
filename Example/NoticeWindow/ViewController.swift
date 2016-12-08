//
//  ViewController.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 12/08/2015.
//  Copyright (c) 2015 Tim van Steenis. All rights reserved.
//

import UIKit
import NoticeWindow

class ViewController: UIViewController {

  @IBAction func presentDefaultSuccessNotice(_ sender: AnyObject) {
    var style = NoticeViewStyle.success
    style.adjustTopInsetForStatusBar = false
    (UIApplication.shared.delegate as? AppDelegate)?.noticeWindow.presentNotice(title: "This is great", message: "Something went very well", style: style)
  }
  
  @IBAction func presentDefaultErrorNotice(_ sender: AnyObject) {
    (UIApplication.shared.delegate as? AppDelegate)?.noticeWindow.presentNotice(title: "Oops", message: "An error has occurred", style: .error)
  }

  @IBAction func presentCustomSuccessNotice(_ sender: AnyObject) {
    Notice(title: "My Custom success notice", style: .Success).present()
  }

  @IBAction func presentCustomErrorNotice(_ sender: AnyObject) {
    Notice(title: "My custom error notice", style: .Error).present()
  }

}
