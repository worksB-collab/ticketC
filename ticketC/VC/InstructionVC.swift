//
//  InstructionVC.swift
//  ticketC
//
//  Created by Billy W on 2020/9/29.
//

import UIKit

class InstructionVC: BaseVC {
    
    private let instructionVM = InstructionVM()
    @IBOutlet weak var lb_about: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lb_info: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        instructionVM.getInfoText()
        setObserver()
        // Do any additional setup after loading the view.
    }
    
    override func setObserver(){
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
        instructionVM.infoText.observe{
            [self] (data) in
            lb_info.text = data
        }
    }
    
    override func setStyle(){
        view.backgroundColor = config.styleColor?.btnTextColor
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: config.styleColor?.titleColor]
        lb_about.textColor = config.styleColor?.infoTextColor
        lb_info.textColor = config.styleColor?.infoTextColor
        switch config.currentStyle.value {
        case .defaultStyle:
            img_icon.image = UIImage(named: "bamboo-sticks-spa-ornament")
        case .xmasStyle:
            img_icon.image = UIImage(named: "hohoho")
        case .birthdayStyle:
            img_icon.image = UIImage(named: "minion8")
        case .none:
            print("no such style for icon")
        }
    }
    
}
