//
//  ViewController.swift
//  NoticeWindow
//
//  Created by Tim van Steenis on 12/08/2015.
//  Copyright (c) 2015 Tim van Steenis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBAction func presentSuccessNotice(sender: AnyObject) {
    Notice(title: "This is great", message: "Something went very well", style: .Success).present()
  }
  
  @IBAction func presentErrorNotice(sender: AnyObject) {
    Notice(title: "Oops", message: "An error has occurred", style: .Error).present()
  }

}
