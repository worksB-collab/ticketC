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
    public var quota = LiveData(0)
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
    
    
    func setQuota() -> Int{
        quota.value = maxTicketNum - upcomingTicketList.count - postTicketList.count
        print("???", quota.value , maxTicketNum , upcomingTicketList.count , postTicketList.count)
        return quota.value
    }
    
    func removeTicktList(){
        postTicketList.removeAll()
        upcomingTicketList.removeAll()
    }
    
}
