//
//  TabBarC.swift
//  ticketC
//
//  Created by Billy W on 2020/11/23.
//

import UIKit

class TabBarC: UITabBarController {
    
    private var secondTimer : Timer?
    private var secondCount : Int = 0
    private var snowArr : [CAShapeLayer] = []
    public let config = Config.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setTabBarStyle()
        setObserver()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if config.currentStyle.value == .xmasStyle{
            return UIStatusBarStyle.lightContent
        }
        return UIStatusBarStyle.default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func setObserver(){
        config.currentStyle.observe{ [self] (data) in
            setTabBarStyle()
        }
    }
    
    func setTabBarStyle(){
        tabBar.barTintColor = config.styleColor?.titleColor
        tabBar.tintColor = config.styleColor?.secondColor
    }
    
}

extension TabBarC: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
