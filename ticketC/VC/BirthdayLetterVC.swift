//
//  BirthdayLetterVC.swift
//  ticketC
//
//  Created by Billy W on 2020/12/9.
//

import UIKit

class BirthdayLetterVC: BaseVC {
    
    private let birthdayLetterVM = BirthdayLetterVM()
    private var header = ""
    private var body = ""
    private var footer = ""
    private var createAt = ""
    
    @IBOutlet weak var view_background: UIView!
    @IBOutlet weak var lb_header: UILabel!
    @IBOutlet weak var lb_body: UILabel!
    @IBOutlet weak var lb_footer: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var create_at: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        birthdayLetterVM.getLetter(user: config.currentUser!)
        setStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        setObserver()
    }
    
    func setObserver() {
        birthdayLetterVM.header.observe{ [self] (data) in
            lb_header.text = data
            header = data
        }
        birthdayLetterVM.body.observe{ [self] (data) in
            lb_body.text = data
            body = data
        }
        birthdayLetterVM.footer.observe{ [self] (data) in
            lb_footer.text = data
            footer = data
        }
        birthdayLetterVM.create_at.observe{ [self] (data) in
            create_at.text = data
            createAt = data
        }
    }
    
    override func setStyle() {
        view.backgroundColor = config.styleColor?.backgroundColor
        contentView.backgroundColor = config.styleColor?.backgroundColor
        lb_header.textColor = config.styleColor?.mainColor
        lb_footer.textColor = config.styleColor?.infoTextColor
        create_at.textColor = config.styleColor?.infoTextColor
        
        let textColor: UIColor = config.styleColor!.infoTextColor
        let underLineColor: UIColor = .lightGray
        let underLineStyle = NSUnderlineStyle.single.rawValue
        let labelAtributes:[NSAttributedString.Key : Any]  = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.underlineStyle: underLineStyle,
            NSAttributedString.Key.underlineColor: underLineColor
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10

        let attrString = NSMutableAttributedString(string: body)
        attrString.addAttributes(labelAtributes, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        lb_body.attributedText = attrString
        lb_body.textAlignment = .justified
    }
}

class UnderlinedLabel: UILabel {

override var text: String? {
    didSet {
        guard let text = text else { return }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
        
        
        }
    }
}
