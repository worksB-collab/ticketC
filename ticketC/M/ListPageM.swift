//
//  ListPageM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation
class ListPageM: BaseM {
    public var ticketSerialNumber = 0
    public var maxTicketNum = 3
    private var quota = 0
    public var postTicketList = [PostTicket](){
        didSet {
            postTicketListListener?(postTicketList)
        }
    }
    typealias PostTicketListListener = ([PostTicket]) -> Void
    var postTicketListListener: PostTicketListListener?
    func observe_postTicketList(listener: PostTicketListListener?) {
        self.postTicketListListener = listener
        listener?(postTicketList)
    }
    
    public var upcomingTicketList = [UpcomingTicket](){
        didSet {
            upcomingTicketListListener?(upcomingTicketList)
        }
    }
    typealias UpcomingTicketListListener = ([UpcomingTicket]) -> Void
    var upcomingTicketListListener: UpcomingTicketListListener?
    func observe_upcomingTicketList(listener: UpcomingTicketListListener?) {
        self.upcomingTicketListListener = listener
        listener?(upcomingTicketList)
    }
    
    
    func getQuota() -> Int{
        quota = maxTicketNum - upcomingTicketList.count - postTicketList.count
        return quota
    }
    
    func removeTicktList(){
        postTicketList.removeAll()
        upcomingTicketList.removeAll()
    }
    
}
