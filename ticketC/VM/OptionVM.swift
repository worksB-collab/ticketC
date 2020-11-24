//
//  OptionVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/24.
//

import Foundation
class OptionVM: BaseVM {
    
    func saveCheckedLogin(data: Bool){
        tools.write(name: "checkedLogin", data: data)
    }
}
