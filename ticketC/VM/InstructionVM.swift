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
    
    func getInfoText(user : String){
                networkController.getFromDatabase(api: "getInfoText" + "/\(user)", callBack: {
                    [self] (jsonData) in
                    let data = jsonData![0]["body"].string
                    instructionM.infoText.value = data ?? "no info"
                })
        print("info text: ", instructionM.infoText.value)
        
    }
}
