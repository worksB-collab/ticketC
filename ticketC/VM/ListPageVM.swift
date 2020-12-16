//
//  ListPageVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation
import SwiftyJSON
class ListPageVM: BaseVM {
    
    private let dateFormatter = DateFormatter()
    private var listPageM = ListPageM()
    public var postTicketList : LiveData<[PostTicket]> = LiveData([])
    public var upcomingTicketList : LiveData<[UpcomingTicket]> = LiveData([])
    public var getDataSuccessful : LiveData<Bool> = LiveData(true)
    public var quota = LiveData(0)
    override init(){
        super.init()
        setObserver()
        dateFormatter.dateFormat = "YYYY/MM/dd"
    }
    
    func setObserver(){
        listPageM.observe_postTicketList{ [self] (data) in
            postTicketList.value = data
        }
        listPageM.observe_upcomingTicketList{ [self] (data) in
            upcomingTicketList.value = data
        }
        networkController.connectionError.observe{ [self] (error) in
            connectionError.value = error
        }
        listPageM.quota.observe{ [self] (data) in
            quota.value = data
        }
    }
    
    func getTicketSerialNumber() -> Int{
        return listPageM.ticketSerialNumber
    }
    
    func getMaxTicketNum() -> Int{
        return listPageM.maxTicketNum
    }
    
    func getTicketData(user : String){
        listPageM.removeTicktList()
        networkController.postToDatabase(api: "getTickets", params: ["user": user], callBack: {
            [self] (jsonData) in
            listPageM.maxTicketNum = jsonData!["quota"].int!
            if jsonData == nil{
                connectionError.value = Config.ERROR_NO_DATA
            }
            let data = jsonData?["tickets"].array
            for i in data!{
                if i["deleted"].int! == 1{
                    continue
                }
                let id = i["id"].int
                let name = i["content"].string
                let data = i["create_at"].string!.split(separator: "T")[0]
                let checked = i["checked"].int
                if checked! == 1{
                    let ticket = PostTicket(name: name!, date: String(data))
                    ticket.id = id!
                    listPageM.postTicketList.insert(ticket, at: 0)
                }else{
                    let ticket = UpcomingTicket(name: name!, date: String(data))
                    ticket.id = id!
                    listPageM.upcomingTicketList.insert(ticket, at: 0)
                }
            }
            connectionError.value = Config.NO_ERROR
            listPageM.setQuota()
        })
    }
    
    func postNewTicket(ticketName : String, user : String){
        networkController.postToDatabase(api: "postNewTicket",
                                         params: ["ticketName": ticketName,
                                                  "user": user],
                                         callBack: { [self] (jsonData) in
                                            if jsonData == nil{
                                                connectionError.value = Config.ERROR_NO_DATA
                                            }
                                            let id = jsonData![0]["id"].int
                                            let name = jsonData![0]["content"].string
                                            let date = jsonData![0]["create_at"].string!.split(separator: "T")[0]
                                            print("added", ticketName)
                                            let newTicket = UpcomingTicket(name: name!, date: String(date))
                                            newTicket.id = id!
                                            upcomingTicketList.value.insert(newTicket, at : 0)
                                            connectionError.value = Config.NO_ERROR
                                         })
    }
    
    func checkTicket(index : Int, ticketSerialNumber : String){
        networkController.postToDatabase(api: "checkTicket",
        params: ["id" : ticketSerialNumber],
        callBack: { [self] (jsonData) in
           if jsonData == nil{
               connectionError.value = Config.ERROR_NO_DATA
           }
           print("checked id", ticketSerialNumber)
           let name = jsonData![0]["content"].string
           let date = jsonData![0]["create_at"].string!.split(separator: "T")[0]
           postTicketList.value.insert(PostTicket(name: name!, date: String(date)), at: 0)
           upcomingTicketList.value.remove(at: index)
           connectionError.value = Config.NO_ERROR
        })
    }
    
    func deleteTicket(ticketSerialNumber : String, index : Int){
        networkController.postToDatabase(api: "deleteTicket",
                                         params: ["id" : ticketSerialNumber],
                                         callBack: { [self] (jsonData) in
                                            if jsonData == nil{
                                                connectionError.value = Config.ERROR_NO_DATA
                                            }
                                            upcomingTicketList.value.remove(at: index)
                                            connectionError.value = Config.NO_ERROR
                                         })
    }
    
}
