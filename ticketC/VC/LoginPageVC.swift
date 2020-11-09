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
    
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var btn_confirm: UIButton!
    @IBAction func btnInstruction(_ sender: UIButton) {
        goToInstructionPage()
    }
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
        if getCheckedLogin(){
            goToNextPage()
            print("auto go to next page")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getCheckedLogin() -> Bool{
        return loginPageVM.getCheckedLogin()
    }
    
    func saveData(name: String, data: Bool){
        loginPageVM.saveData(name: "checkedLogin", data: checkedLogin)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "navListPageVC") as! UINavigationController
        
        if navigationController != nil{
            let vc = storyboard.instantiateViewController(withIdentifier: "ListPageVC") as! UIViewController
            navigationController?.pushViewController(vc, animated: true)
        }else{
            present(vc,animated: true,completion: nil)
        }
    }
}
