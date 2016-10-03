//
//  ViewController.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 12/08/2015.
//  Copyright (c) 2015 Tim van Steenis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBAction func presentDefaultSuccessNotice(_ sender: AnyObject) {
    (UIApplication.shared.delegate as? AppDelegate)?.noticeWindow.presentNotice("This is great", message: "Something went very well", style: .success)
  }
  
  @IBAction func presentDefaultErrorNotice(_ sender: AnyObject) {
    (UIApplication.shared.delegate as? AppDelegate)?.noticeWindow.presentNotice("Oops", message: "An error has occurred", style: .error)
  }

  @IBAction func presentCustomSuccessNotice(_ sender: AnyObject) {
    Notice(title: "My Custom success notice", style: .success).present()
  }

  @IBAction func presentCustomErrorNotice(_ sender: AnyObject) {
    Notice(title: "My custom error notice", style: .error).present()
  }

}
