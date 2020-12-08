//
//  PostTVC.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class PostTVC2: BaseTVC {

    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var ticket_name: UILabel!
    @IBOutlet weak var added_date: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setStyle(){
        switch config.currentStyle.value{
        case .defaultStyle:
            img_icon.image = UIImage(named: "fat_panda")
        case .xmasStyle:
            img_icon.image = UIImage(named: "gift-box")
        case .birthdayStyle:
            img_icon.image = UIImage(named: "minion5")
        case .none:
            break
        }
        ticket_name.textColor = config.styleColor?.titleColor
        added_date.textColor = config.styleColor?.infoTextColor
        contentView.backgroundColor = config.styleColor?.backgroundColor
    }
    
    class var nibName: String {
        return "PostTVC2"
    }
    
    
}


