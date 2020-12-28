//
//  BaseNavC.swift
//  ticketC
//
//  Created by Billy W on 2020/12/9.
//

import UIKit

class BaseNavC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override var preferredStatusBarStyle : UIStatusBarStyle {

        if let topVC = viewControllers.last {
            //return the status property of each VC, look at step 2
            return topVC.preferredStatusBarStyle
        }
        return .default
    }

}
