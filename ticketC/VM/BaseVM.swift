//
//  BaseVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation
class BaseVM: NSObject {
    public let tools = Tools.sharedInstance
    public let networkController = NetworkController.sharedInstance
    public let today = Date()
}
