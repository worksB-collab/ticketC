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
    
    func getLetter(){
        networkController.getFromDatabase(api: "getBirthdayLetter", callBack: { [self] (jsonData) in
            header.value = jsonData![0]["header"].string!
            body.value = jsonData![0]["body"].string!
            footer.value = jsonData![0]["footer"].string!
            create_at.value = String(jsonData![0]["create_at"].string!.split(separator: "T")[0])
        })
    }
}
