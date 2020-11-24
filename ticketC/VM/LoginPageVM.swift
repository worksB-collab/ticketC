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
    
    
}
