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
        setTabBarStyle()
        setObserver()
        setSecondTimer()
    }
    
    func setObserver(){
        config.currentStyle.observe{ [self] (data) in
            setTabBarStyle()
//            if data != .xmasStyle{
//                stopSecondTimer()
//            }
        }
    }
    
    func setTabBarStyle(){
        tabBar.barTintColor = config.styleColor?.titleColor
        tabBar.tintColor = config.styleColor?.secondColor
    }
    
    
    func generateCircle(){
        let circleSize = getRandomNum(min: 0, max: 5)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: Int(getRandomNum(min: 0, max: Float(view.frame.width))), y: -10),
                                      radius: CGFloat(circleSize),
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
            
        // Change the fill color
        shapeLayer.fillColor = UIColor(red: 255, green: 255, blue: 255, alpha: CGFloat(getRandomNum(min: 0, max: 1))).cgColor
        // You can change the stroke color
//        shapeLayer.strokeColor = UIColor(red: 255, green: 255, blue: 255, alpha: CGFloat(getRandomNum(min: 0, max: 1))).cgColor
        // You can change the line width
//        shapeLayer.lineWidth = CGFloat(circleSize/getRandomNum(min: 0, max: 1))
            
        view.layer.addSublayer(shapeLayer)
        snowArr.append(shapeLayer)
    }
    
    func getRandomNum(min : Float, max : Float) -> Float{
        return Float.random(in: min...max)
    }
    
    //timer
    func setSecondTimer(){
        if secondTimer == nil {
            secondTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.secondTimerFunc), userInfo: nil, repeats: true)
        }
    }
    
    @objc func secondTimerFunc(){
        secondCount += 1
        if config.currentStyle.value == .xmasStyle{
            if getRandomNum(min: 0, max: 10) > 9{
                generateCircle()
            }
            for i in snowArr{
                let horizontalMove = Int(getRandomNum(min: -3, max: 3))
                i.position = CGPoint(x: Int(i.position.x) - horizontalMove, y: (Int(i.position.y) + 4) + Int(i.lineWidth) - abs(horizontalMove))
                if i.position.y >= view.frame.height + 10 {
                    i.removeFromSuperlayer()
                }
            }
        }else{
            stopSecondTimer()
            removeSnow()
        }
    }
    
    func stopSecondTimer(){
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

}
