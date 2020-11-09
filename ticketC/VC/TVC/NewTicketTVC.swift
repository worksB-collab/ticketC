//
//  TableViewCell.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class NewTicketTVC: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var tf_ticket_name: UITextField!
    @IBOutlet weak var btn_confirm: UIButton!
    @IBAction func btn_confirm(_ sender: UIButton) {
        tf_ticket_name.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tf_ticket_name.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class var reuseIdentifier: String {
        return "NewTicketTVC"
    }
    
    class var nibName: String {
        return "NewTicketTVC"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissMyKeyboard()
        return true
    }
    
    @objc func dismissMyKeyboard(){
        self.contentView.endEditing(true)
    }
    
}
