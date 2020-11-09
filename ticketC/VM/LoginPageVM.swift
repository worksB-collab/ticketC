//
//  LoginPageVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation

class LoginPageVM: BaseVM {
    
    func getCheckedLogin() -> Bool{
        do {
            if let data = Config.userDefaults.data(forKey:"checkedLogin") {
                let res = try JSONDecoder().decode(Bool.self,from:data)
                return res
            } else {
                print("No data")
            }
        }
        catch { print(error) }
        print("no data")
        return false
    }
    
    func saveData(name: String, data: Bool){
        do {
            let res = try JSONEncoder().encode(data)
            Config.userDefaults.set(res,forKey: name)
        }
        catch { print(error) }
    }
    
}
