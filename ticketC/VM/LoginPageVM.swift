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
        networkController.getFromDatabase(api: "getQuota", callBack: { [self] (jsonData) in
            if jsonData == nil || jsonData![0]["quota"].int == nil{
                networkController.isDatabaseAlive = false
            }else{
                networkController.isDatabaseAlive = true
                print("success", jsonData![0]["quota"].int)
            }
        })
    }
    
    func isDatabaseChecked() -> Bool?{
        return networkController.isDatabaseAlive
    }
    
}
