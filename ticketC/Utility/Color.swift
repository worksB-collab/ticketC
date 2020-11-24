//
//  Color.swift
//  ticketC
//
//  Created by Billy W on 2020/11/23.
//

import Foundation
import UIKit

protocol BaseStyleColor {
    var mainColor : UIColor { get }
    var secondColor : UIColor { get }
    var backgroundColor : UIColor { get }
    var titleColor : UIColor { get }
    var infoTextColor : UIColor { get }
    var btnTextColor : UIColor { get }
}

class DefaultStyleColor : BaseStyleColor{
    var mainColor = UIColor(rgb: 0x5856D6)
    var secondColor = UIColor(rgb: 0xFFFFFF)
    var backgroundColor = UIColor(rgb: 0xFFFFFF)
    var titleColor = UIColor(rgb: 0x5856D6)
    var infoTextColor = UIColor(rgb: 0x5856D6)
    var btnTextColor = UIColor(rgb: 0xFFFFFF)
}

class XmasStyleColor : BaseStyleColor{
    //test
    var mainColor = UIColor(rgb: 0xBF0436)
    var secondColor = UIColor(rgb: 0x088C74)
    var backgroundColor = UIColor(rgb: 0x000000)
    var titleColor = UIColor(rgb: 0xFFFFFF)
    var infoTextColor = UIColor(rgb: 0xF2C744)
    var btnTextColor = UIColor(rgb: 0xFFFFFF)
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
