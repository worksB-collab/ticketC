//
//  BaseTVC.swift
//  ticketC
//
//  Created by Billy W on 2020/11/23.
//

import UIKit

class BaseTVC: UITableViewCell {

    public let config = Config.sharedInstance
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        contentView.layer.cornerRadius = 5
//        contentView.clipsToBounds = true
//        contentView.backgroundColor = UIColor.clear
//        contentView.layer.shadowColor = UIColor.darkGray.cgColor
//        contentView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        contentView.layer.shadowOpacity = 0.6
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyle()
        setObserver()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setObserver(){
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
    }
    
    func setStyle(){}
}
