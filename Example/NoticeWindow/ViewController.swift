//
//  ViewController.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 12/08/2015.
//  Copyright (c) 2015 Tim van Steenis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBAction func presentDefaultSuccessNotice(sender: AnyObject) {
    (UIApplication.sharedApplication().delegate as? AppDelegate)?.noticeWindow.presentNotice("This is great", message: "Something went very well", style: .Success)
  }
  
  @IBAction func presentDefaultErrorNotice(sender: AnyObject) {
    (UIApplication.sharedApplication().delegate as? AppDelegate)?.noticeWindow.presentNotice("Oops", message: "An error has occurred", style: .Error)
  }

  @IBAction func presentCustomSuccessNotice(sender: AnyObject) {
    Notice(title: "My Custom success notice", style: .Success).present()
  }

  @IBAction func presentCustomErrorNotice(sender: AnyObject) {
    Notice(title: "My custom error notice", style: .Error).present()
  }

}
