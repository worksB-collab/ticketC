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
    
    func setObserver(){
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
    }
    
    func snowFlicking(){
        setSecondTimer()
    }

    func generateCircle(){
        let circleSize = getRandomNum(min: 0, max: 6)
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
        shapeLayer.strokeColor = UIColor(red: 255, green: 255, blue: 255, alpha: CGFloat(getRandomNum(min: 0, max: 1))).cgColor
        // You can change the line width
        shapeLayer.lineWidth = CGFloat(circleSize/getRandomNum(min: 3, max: 5))

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
        if getRandomNum(min: 0, max: 10) > 9{
            generateCircle()
        }
        for i in snowArr{
            i.position = CGPoint(x: Int(i.position.x) - Int(getRandomNum(min: -1, max: 1)), y: Int(i.position.y) + 4)
            if i.position.y >= view.frame.height {
                i.removeFromSuperlayer()
            }
        }

    }

    func stopSecondTimer(){
        if secondTimer != nil{
            secondTimer?.invalidate()
            secondTimer = nil
        }
    }
    
    
    func setStyle(){}
}
