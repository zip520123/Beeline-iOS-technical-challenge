//
//  ViewController.swift
//  Beeline
//
//  Created by zip520123 on 28/08/2020.
//  Copyright © 2020 zip520123. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let label = UILabel()
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    view.backgroundColor = .white
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Welcome, please turn on the location Privacy to continue."
    label.numberOfLines = 0
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
    label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 16).isActive = true
  }

}

