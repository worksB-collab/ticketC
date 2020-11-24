//
//  OptionTVC.swift
//  ticketC
//
//  Created by Billy W on 2020/11/23.
//

import UIKit

class OptionTVC: BaseTVC {

    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var img_icon: UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setStyle(){
        switch config.currentStyle.value{
        case .defaultStyle:
            img_icon.image = UIImage(named: "pandaA")
        case .xmasStyle:
            img_icon.image = UIImage(named: "candy-cane")
        case .none:
            break
        }
        lb_name.textColor = config.styleColor?.titleColor
        contentView.backgroundColor = config.styleColor?.backgroundColor
    }
    
    class var reuseIdentifier: String {
        return "OptionTVC"
    }
    
    class var nibName: String {
        return "OptionTVC"
    }
}
