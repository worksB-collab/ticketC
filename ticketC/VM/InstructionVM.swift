//
//  InstructionVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/24.
//

import Foundation
class InstructionVM : BaseVM {
    
    private let instructionM = InstructionM()
    public var infoText : LiveData<String> = LiveData("")
    
    override init() {
        super.init()
        setObserver()
    }
    
    func setObserver(){
        instructionM.infoText.observe{
            [self] (data) in
            infoText.value = data
        }
    }
    
    func getInfoTextFromSheet(){
        networkController.postToSheet(params: ["command": "getInfoText"], callBack: { [self] (jsonData) in
            let status = jsonData!["status"].int
            let data = jsonData!["data"].dictionary
            if status != 200{
                connectionError.value = Config.ERROR_NO_DATA
            }
            let content = data!["infoText"]?.stringValue
            instructionM.infoText.value = content ?? "no info"
        })
        print("info text: ", instructionM.infoText.value)
        
    }
    
//    func getInfoText(user : String){
//                networkController.getFromDatabase(api: "getInfoText" + "/\(user)", callBack: {
//                    [self] (jsonData) in
//                    let data = jsonData![0]["body"].string
//                    instructionM.infoText.value = data ?? "no info"
//                })
//        print("info text: ", instructionM.infoText.value)
//
//    }
}
