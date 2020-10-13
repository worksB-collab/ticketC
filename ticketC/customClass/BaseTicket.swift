//
//  BaseTicket.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import Foundation

class BaseTicket: Codable{
    var name : String?
    var date : String?
    var index : Int?
    var id : Int?
    init(name : String, date : String) {
        self.name = name
        self.date = date
    }
    
}

class PostTicket: BaseTicket {
}

class UpcomingTicket: BaseTicket {
}
