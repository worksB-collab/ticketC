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
        return UIStatusBarStyle.darkContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        setBaseObserver()
        setSnowSecondTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopSnowSecondTimer()
    }
    
    func setBaseObserver(){
        config.currentStyle.observe{ [self] _ in
            removeSnow()
            setStyle()
            setSnowSecondTimer()
        }
    }
    
    deinit {
        print("deinit", self)
    }
    
    func setSnowSecondTimer(){
        if secondTimer == nil {
            secondTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.baseSecondTimerFunc), userInfo: nil, repeats: true)
            RunLoop.current.add(secondTimer!, forMode: RunLoop.Mode.common)
        }
    }

    @objc func baseSecondTimerFunc(){
        if config.currentStyle.value == .xmasStyle{
            if getRandomNum(min: 0, max: 10) > 7{
                generateCircle()
            }
            for i in 0..<snowArr.count{
                var left : Float = 0
                var right : Float = 0
                if isEvenDate(){
                    left = 3.0
                }else{
                    right = 3.0
                }
                let horizontalMove = Int(getRandomNum(min: 0 - left, max: 0 + right))
                snowArr[i].position = CGPoint(x: Int(snowArr[i].position.x) + horizontalMove,
                                     y: (Int(snowArr[i].position.y) + 4) + Int(snowArr[i].lineWidth) - abs(horizontalMove))
                
//                if snowArr[i].position.y >= view.frame.height + 10 {
//                    snowArr[i].removeFromSuperlayer()
//                    print("snowArr removeFromSuperlayer", snowArr[i].position.y, view.frame.height)
                //                }
            }
            if snowArr.count != 0{
                if snowArr.first!.position.y >= view.frame.height + 10 {
                    snowArr.first!.removeFromSuperlayer()
                    snowArr.remove(at: 0)
                }
            }
        }else{
            removeSnow()
        }
    }
    
    func stopSnowSecondTimer(){
        if secondTimer != nil{
            secondTimer?.invalidate()
            secondTimer = nil
        }
    }
    
    func removeSnow(){
        for i in snowArr{
            i.removeFromSuperlayer()
        }
    }
    
    func isEvenDate() -> Bool{
        if Int(config.dateStr!.suffix(2))! % 2 == 0{
            return true
        }
        return false
    }
    
    func generateCircle(){
        let circleSize = Int(getRandomNum(min: 0, max: 10))
        var left : CGFloat = 0
        var right : CGFloat = 0
        
        if isEvenDate(){
            right = 100.0
        }else{
            left = 100.0
        }
        
        let circleLayer = CAShapeLayer();
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: Int(getRandomNum(min: Float(0 - left), max: Float(view.frame.width + right))), y: -10, width: circleSize, height: circleSize)).cgPath;
            
        // Change the fill color
        circleLayer.fillColor = UIColor(red: CGFloat(Double(circleSize*25)/255.0),
                                        green: CGFloat(Double(circleSize*25)/255.0),
                                        blue: CGFloat(Double(circleSize*25)/255.0),
                                        alpha: 1).cgColor
        let index = UInt32(getRandomNum(min: 0, max: 2))
        view.layer.insertSublayer(circleLayer, at: index)
        snowArr.append(circleLayer)
    }

    func getRandomNum(min : Float, max : Float) -> Float{
        return Float.random(in: min...max)
    }

    func setStyle(){}
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
