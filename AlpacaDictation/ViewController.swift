//
//  ViewController.swift
//  AlpacaDictation
//
//  Created by Masataka Hirano on 2017/07/31.
//  Copyright © 2017 Masataka Hirano. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
  
  var message: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print(message ?? "")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func cancel(_ sender: UIBarButtonItem) {
    if presentingViewController is UINavigationController {
      dismiss(animated: true, completion: nil)
    } else if let owingNavigationController = navigationController {
      owingNavigationController.popViewController(animated: true)
    }
  }

}

