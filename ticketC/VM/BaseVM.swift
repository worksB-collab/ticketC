//
//  BaseVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation
class BaseVM: NSObject {
    public let tools = Tools.sharedInstance
    public let config = Config.sharedInstance
    public let networkController = NetworkController.sharedInstance
    public let today = Date()
    
    func isKeepUsingDatabase()->Bool{
        var alive : Bool? = tools.read(name: "database")
        if alive == nil{
            alive = true
        }
        return alive!
    }
    
}
