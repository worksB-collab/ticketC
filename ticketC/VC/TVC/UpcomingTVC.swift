//
//  UpcomingTVC.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class UpcomingTVC: BaseTVC {
    
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var ticket_name: UILabel!
    @IBOutlet weak var btn_check: UIButton!
    
    @IBOutlet weak var added_date: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setLocalizedStrings(){
        btn_check.setTitle("兌換".localized, for: .normal)
    }
    
    override func setStyle(){
        switch config.currentStyle.value{
        case .defaultStyle:
            img_icon.image = UIImage(named: "bamboo-canes")
        case .xmasStyle:
            img_icon.image = UIImage(named: "christmas-sock")
        case .minionStyle:
            img_icon.image = UIImage(named: "minion2")
        case .none:
            break
        }
        ticket_name.textColor = config.styleColor?.titleColor
        btn_check.setTitleColor(config.styleColor?.btnTextColor, for: .normal)
        btn_check.backgroundColor = config.styleColor?.mainColor
        added_date.textColor = config.styleColor?.infoTextColor
        contentView.backgroundColor = config.styleColor?.backgroundColor
    }
    
    class var nibName: String {
            return "UpcomingTVC"
        }
    
}
