//
//  BaseVC.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import UIKit
import Foundation

class BaseVC: UIViewController {
    
    public let config = Config.sharedInstance
    public let today = Date()
    private var secondTimer : Timer?
    private var secondCount : Int = 0
    private var snowArr : [CAShapeLayer] = []
    public var connectionError = Config.NO_ERROR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if config.currentStyle.value == .xmasStyle{
            return UIStatusBarStyle.lightContent
        }
        return UIStatusBarStyle.default
    }
    
    override func viewWillLayoutSubviews() {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func setObserver(){
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
    }
    
    func setSecondTimer(){
        if secondTimer == nil {
            secondTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.secondTimerFunc), userInfo: nil, repeats: true)
        }
    }

    @objc func secondTimerFunc(){
        secondCount += 1
        stopSecondTimer()
    }

    func stopSecondTimer(){
        if secondTimer != nil{
            secondTimer?.invalidate()
            secondTimer = nil
        }
    }
    
    func setStyle(){}
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
