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
    
    func getInfoText(){
        networkController.postToSheet(params: ["command" : "getInfoText"], callBack: {
            [self] (jsonData) in
            if jsonData!["status"].int == 200{
                let data = jsonData!["data"]["infoText"].string
                instructionM.infoText.value = data!
            }else{
                instructionM.infoText.value = "找不到資料"
            }
        })
    }
}