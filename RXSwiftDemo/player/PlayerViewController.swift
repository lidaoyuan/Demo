//
//  PlayerViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/13.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let p = PlayerView(frame: self.view.frame)
        self.view.addSubview(p)
    }
    

    

}
