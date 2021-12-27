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
    
    func getLetterFromSheet(){
        networkController.postToSheet(params: ["command": "getBirthdayLetter"], callBack: { [self] (jsonData) in
            let status = jsonData!["status"].int
            let data = jsonData!["data"].dictionary
            if status != 200{
                connectionError.value = Config.ERROR_NO_DATA
            }
            header.value = data!["header"]!.stringValue
            body.value = data!["body"]!.stringValue
            footer.value = data!["footer"]!.stringValue
            create_at.value = String((data!["create_at"]!.string!.split(separator: "T")[0]))
        })
    }
    
//    func getLetter(user : String){
//        networkController.getFromDatabase(api: "getBirthdayLetter" + "/\(user)", callBack: { [self] (jsonData) in
//            header.value = jsonData![0]["header"].string!
//            body.value = jsonData![0]["body"].string!
//            footer.value = jsonData![0]["footer"].string!
//            create_at.value = String(jsonData![0]["create_at"].string!.split(separator: "T")[0])
//        })
//    }
}
