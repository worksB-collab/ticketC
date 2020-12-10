//
//  BirthdayLetterVC.swift
//  ticketC
//
//  Created by Billy W on 2020/12/9.
//

import UIKit

class BirthdayLetterVC: BaseVC {
    
    private let birthdayLetterVM = BirthdayLetterVM()

    @IBOutlet weak var lb_header: UILabel!
    @IBOutlet weak var lb_body: UILabel!
    @IBOutlet weak var lb_footer: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var create_at: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        birthdayLetterVM.getLetter()
        setObserver()
        setStyle()
    }
    
    override func setObserver() {
        birthdayLetterVM.header.observe{ [self] (data) in
            lb_header.text = data
        }
        birthdayLetterVM.body.observe{ [self] (data) in
            lb_body.text = data
        }
        birthdayLetterVM.footer.observe{ [self] (data) in
            lb_footer.text = data
        }
        birthdayLetterVM.create_at.observe{ [self] (data) in
            create_at.text = data
        }
    }
    
    override func setStyle() {
        view.backgroundColor = config.styleColor?.backgroundColor
        contentView.backgroundColor = config.styleColor?.backgroundColor
        lb_header.textColor = config.styleColor?.mainColor
        lb_body.textColor = config.styleColor?.infoTextColor
        lb_footer.textColor = config.styleColor?.infoTextColor
        create_at.textColor = config.styleColor?.mainColor
        
    }


}
