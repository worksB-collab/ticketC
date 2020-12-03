//
//  LoginPageVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation

class LoginPageVM: BaseVM {
    
    func getCheckedLogin() -> Bool?{
        return tools.read(name: "checkedLogin")
    }
    
    func saveCheckedLogin(data: Bool){
        tools.write(name: "checkedLogin", data: data)
    }
    
    func unlockEmbargo(){
        config.embargo = false
        tools.write(name: "embargo", data: false)
    }
    
    override init() {
        super.init()
        isDatabaseAlive()
    }
    
    
    func isDatabaseAlive(){
        networkController.getFromDataBase(callBack: { [self] (jsonData) in
            print("success", jsonData![0]["quota"].int)
            if jsonData![0]["quota"].int != nil{
                networkController.isDatabaseAlive = true
            }else{
                networkController.isDatabaseAlive = false
            }
        })
    }
    
}
