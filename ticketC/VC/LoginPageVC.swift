//
//  LoginPageVC.swift
//  ticketC
//
//  Created by Billy W on 2020/9/29.
//

import UIKit

class LoginPageVC: BaseVC, UITextFieldDelegate {
    
    private var validName : String = "Christina"
    private var checkedLogin : Bool = false
    private var loginPageVM = LoginPageVM()
    private var secondTimer : Timer?
    private var secondCount : Int = 0
    private var snowArr : [CAShapeLayer] = []
    private var initLoginCheck = true
    
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var btn_confirm: UIButton!
    @IBAction func btn_confirm(_ sender: UIButton) {
        if tf_name.text != "" {
            if (tf_name.text! == validName || tf_name.text! == validName + " "){
                checkedLogin = true
                saveData(name: "checkedLogin", data: checkedLogin)
                goToNextPage()
                print("go to next page")
            }else{
                goToInstructionPage()
                print("go to Instruction page")
            }
        }else{
            goToInstructionPage()
            print("go to Instruction page")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tf_name.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
        setSecondTimer()
        setObserver()
        
        
        img_icon.isUserInteractionEnabled = true
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressRecognizer.minimumPressDuration = 2.0
        img_icon.addGestureRecognizer(longPressRecognizer)
    }
    
    func generateCircle(){
        let circleSize = getRandomNum(min: 0, max: 5)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: Int(getRandomNum(min: 0, max: Float(view.frame.width))), y: -10),
                                      radius: CGFloat(circleSize),
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
            
        // Change the fill color
        shapeLayer.fillColor = UIColor(red: 255, green: 255, blue: 255, alpha: CGFloat(getRandomNum(min: 0, max: 1))).cgColor
        // You can change the stroke color
//        shapeLayer.strokeColor = UIColor(red: 255, green: 255, blue: 255, alpha: CGFloat(getRandomNum(min: 0, max: 1))).cgColor
        // You can change the line width
//        shapeLayer.lineWidth = CGFloat(circleSize/getRandomNum(min: 0, max: 1))
            
//        view.layer.addSublayer(shapeLayer)
        let index = UInt32(getRandomNum(min: 0, max: 2))
        view.layer.insertSublayer(shapeLayer, at: index)
        snowArr.append(shapeLayer)
    }

    func getRandomNum(min : Float, max : Float) -> Float{
        return Float.random(in: min...max)
    }

    //timer
    override func setSecondTimer(){
        if secondTimer == nil {
            secondTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.secondTimerFunc), userInfo: nil, repeats: true)
        }
    }

    @objc override func secondTimerFunc(){
        secondCount += 1
        if config.currentStyle.value == .xmasStyle{
            if getRandomNum(min: 0, max: 10) > 9{
                generateCircle()
            }
            for i in snowArr{
                let horizontalMove = Int(getRandomNum(min: -3, max: 3))
                i.position = CGPoint(x: Int(i.position.x) - horizontalMove, y: (Int(i.position.y) + 4) + Int(i.lineWidth) - abs(horizontalMove))
                if i.position.y >= view.frame.height + 10 {
                    i.removeFromSuperlayer()
                }
            }
        }else{
            stopSecondTimer()
            removeSnow()
        }
        
        if loginPageVM.isDatabaseChecked() != nil{
            if initLoginCheck{
                if getCheckedLogin(){
                    goToNextPage()
                    print("auto go to next page")
                    stopSecondTimer()
                }else{
                    initLoginCheck = false
                }
            }
        }
    }

    override func stopSecondTimer(){
        if secondTimer != nil{
            secondTimer?.invalidate()
            secondTimer = nil
        }
    }
    
    func removeSnow(){
        for i in snowArr{
            i.removeFromSuperlayer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        setStyle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func setStyle(){
        switch config.currentStyle.value {
        case .defaultStyle:
            self.view.backgroundColor = config.styleColor?.backgroundColor
            img_icon.image = UIImage(named: "pandaB")
            lb_title.textColor = config.styleColor?.titleColor
            tf_name.backgroundColor = UIColor.clear
            tf_name.layer.borderColor = config.styleColor?.mainColor.cgColor
            tf_name.layer.borderWidth = 1.0
            tf_name.layer.cornerRadius = 5
            tf_name.textColor = config.styleColor?.mainColor
            btn_confirm.layer.borderWidth = 0.0
            btn_confirm.backgroundColor = config.styleColor?.mainColor
            btn_confirm.setTitleColor(config.styleColor?.secondColor, for: .normal)
        case .xmasStyle:
            self.view.backgroundColor = config.styleColor?.backgroundColor
            img_icon.image = UIImage(named: "christmas-wreath")
            lb_title.textColor = config.styleColor?.titleColor
            tf_name.backgroundColor = UIColor.clear
            tf_name.layer.borderWidth = 1.0;
            tf_name.layer.cornerRadius = 5
            tf_name.layer.borderColor = config.styleColor?.titleColor.cgColor
            tf_name.textColor = config.styleColor?.titleColor
            btn_confirm.backgroundColor = UIColor.clear
            btn_confirm.layer.borderWidth = 1.0
            btn_confirm.layer.borderColor = config.styleColor?.titleColor.cgColor
            btn_confirm.setTitleColor(config.styleColor?.secondColor, for: .normal)
            print("xmas")
        case .none:
            print("cannot set color")
        }
        setSecondTimer()
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        let controller = UIAlertController(title: "已解鎖 1/27 DLC", message: "專屬於吳太太的更新已安裝完成", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "太好啦！", style: .default, handler: nil)
        controller.addAction(okAction)
        controller.view.tintColor = config.styleColor?.mainColor
        present(controller, animated: true, completion: nil)
    }
    
    func unlockEmbargo(){
        loginPageVM.unlockEmbargo()
    }
    
    func getCheckedLogin() -> Bool{
        let result = loginPageVM.getCheckedLogin()
        if result != nil{
            return result!
        }
        return false
    }
    
    func saveData(name: String, data: Bool){
        loginPageVM.saveCheckedLogin(data: checkedLogin)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tf_name {
            textField.resignFirstResponder()
            btn_confirm.becomeFirstResponder()
            dismissMyKeyboard()
        }
        return true
    }
    
    func goToInstructionPage(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InstructionVC") as! InstructionVC
        present(vc,animated: true,completion: nil)
    }
    
    func goToNextPage() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "navListPageVC") as! UINavigationController
//
//        if navigationController != nil{
//            let vc = storyboard.instantiateViewController(withIdentifier: "ListPageVC") as! UIViewController
//            navigationController?.pushViewController(vc, animated: true)
//        }else{
//            present(vc,animated: true,completion: nil)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TBC") as! UITabBarController
        
//        if navigationController != nil{
//            let vc = storyboard.instantiateViewController(withIdentifier: "ListPageVC") as! UIViewController
//            navigationController?.pushViewController(vc, animated: true)
//        }else{
        vc.modalPresentationStyle = .fullScreen
            present(vc,animated: true,completion: nil)
//        }
    }
}
