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
        instructionVM.getInfoText(user: config.currentUser!)
        setObserver()
        setLocalizedStrings()
    }
    
    func setObserver(){
        instructionVM.infoText.observe{
            [self] (data) in
            lb_info.text = data
        }
    }
    
    func setLocalizedStrings(){
        lb_about.text = "關於".localized
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
        case .minionStyle:
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)); // set as you want
            let image = UIImage(named: "minion7");
            imageView.image = image;
            self.view.insertSubview(imageView, at: 0);
            img_icon.isHidden = true
            lb_about.isHidden = true
        case .none:
            print("no such style for icon")
        }
    }
    
}
