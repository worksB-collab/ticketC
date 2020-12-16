//
//  TableViewCell.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class NewTicketTVC: BaseTVC, UITextFieldDelegate {
    
    @IBOutlet weak var tf_ticket_name: UITextField!
    @IBOutlet weak var btn_confirm: UIButton!
    @IBAction func btn_confirm(_ sender: UIButton) {
        tf_ticket_name.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tf_ticket_name.delegate = self
        setStyle()
        setObserver()
        setLocalizedStrings()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setObserver(){
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
    }
    
    override func setLocalizedStrings(){
        btn_confirm.setTitle("新增".localized, for: .normal)
    }
    
    override func setStyle(){
        tf_ticket_name.textColor = config.styleColor?.titleColor
        tf_ticket_name.tintColor = config.styleColor?.titleColor
        tf_ticket_name.backgroundColor = config.styleColor?.backgroundColor
        btn_confirm.setTitleColor(config.styleColor?.titleColor, for: .normal)
        contentView.backgroundColor = config.styleColor?.backgroundColor
        btn_confirm.backgroundColor = UIColor.clear
        btn_confirm.layer.borderWidth = 1.0
        btn_confirm.layer.cornerRadius = 5
        btn_confirm.layer.borderColor = config.styleColor?.titleColor.cgColor
        tf_ticket_name.backgroundColor = UIColor.clear
        tf_ticket_name.layer.borderWidth = 1.0
        tf_ticket_name.layer.cornerRadius = 5
        tf_ticket_name.layer.borderColor = config.styleColor?.titleColor.cgColor
        
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
