//
//  UpcomingTVC.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class UpcomingTVC: UITableViewCell {

    @IBOutlet weak var ticket_name: UILabel!
    @IBOutlet weak var btn_check: UIButton!
    @IBOutlet weak var added_date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class var nibName: String {
            return "UpcomingTVC"
        }
    
}
