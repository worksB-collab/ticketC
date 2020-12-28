//
//  BirthdayLetterVM.swift
//  ticketC
//
//  Created by Billy W on 2020/12/10.
//

import Foundation
class BirthdayLetterVM: BaseVM {
    
    public var header = LiveData("")
    public var body = LiveData("")
    public var footer = LiveData("")
    public var create_at = LiveData("")
    
    func getLetter(user : String){
        networkController.getFromDatabase(api: "getBirthdayLetter" + "/\(user)", callBack: { [self] (jsonData) in
            header.value = jsonData![0]["header"].string!
            body.value = jsonData![0]["body"].string!
            footer.value = jsonData![0]["footer"].string!
            create_at.value = String(jsonData![0]["create_at"].string!.split(separator: "T")[0])
        })
    }
}
