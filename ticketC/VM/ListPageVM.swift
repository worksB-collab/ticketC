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
    }
    
    func getQuota() -> Int{
        return listPageM.getQuota()
    }
    
    func getTicketSerialNumber() -> Int{
        return listPageM.ticketSerialNumber
    }
    
    func getMaxTicketNum() -> Int{
        return listPageM.maxTicketNum
    }
    
    func isDatabaseAlive()->Bool{
        if let _ = networkController.isDatabaseAlive{
            if networkController.isDatabaseAlive!{
                print("alive")
                return true
            }else{
                print("not alive1")
                return false
            }
        }else{
            print("not alive 2")
            return false
        }
    }
    
    func getTicketData(){
        listPageM.removeTicktList()
        if isDatabaseAlive(){
            networkController.getFromDatabase(api: "getQuota", callBack: {
                [self] (jsonData) in
                listPageM.maxTicketNum = jsonData![0]["quota"].int!
            })
            networkController.getFromDatabase(api: "getTickets", callBack: {
                [self] (jsonData) in
                structureTicketsFromDatabase(jsonData : jsonData)
            })
        }else{
            networkController.postToSheet(params: ["command": "getTickets"], callBack: { [self]
                (jsonData) in
                if jsonData!["status"].int == 200{
                    structureTicketsFromSheet(jsonData : jsonData)
                }else{
                    getDataSuccessful.value = false
                    print("error", jsonData?.debugDescription)
                }
            })
        }
    }
    
    func structureTicketsFromDatabase(jsonData : JSON?){
        let data = jsonData?.array
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
    }
    
    func structureTicketsFromSheet(jsonData : JSON?){
        if jsonData != nil{
            let data = jsonData!["data"]
            if data["ticketNum"].string == nil{
                listPageM.maxTicketNum = data["ticketNum"].int!
            }else{
                listPageM.maxTicketNum = Int(data["ticketNum"].string!)!
            }
            let tickets = data["tickets"].array
            if !tickets!.isEmpty{
                listPageM.ticketSerialNumber = tickets!.count
                for i in 0..<tickets!.count{
                    let ticketDeleted = tickets![i]["ticketDeleted"].bool
                    if ticketDeleted!{
                        continue
                    }
                    var ticketSerialNumber = tickets![i]["ticketSerialNumber"].int
                    if ticketSerialNumber == nil{
                        ticketSerialNumber = Int(tickets![i]["ticketSerialNumber"].string!)
                    }
                    var ticketName : String?
                    if tickets![i]["ticketName"].string == nil{
                        ticketName = "\(tickets![i]["ticketName"].int)"
                    }else{
                        ticketName = tickets![i]["ticketName"].string
                    }
                    
                    let ticketDateArr = tickets![i]["ticketDate"].string!.split(separator: "T")
                    let ticketDate = ticketDateArr[0]
                    let ticketChecked = tickets![i]["ticketChecked"].bool
                    
                    if ticketChecked!{
                        let ticket = PostTicket(name: ticketName!, date: String(ticketDate))
                        ticket.id = ticketSerialNumber!
                        listPageM.postTicketList.insert(ticket, at: 0)
                    }else{
                        let ticket = UpcomingTicket(name: ticketName!, date: String(ticketDate))
                        ticket.id = ticketSerialNumber!
                        listPageM.upcomingTicketList.insert(ticket, at: 0)
                    }
                }
            }
        }
    }
    
    func postNewTicket(ticketName : String){
        if isDatabaseAlive(){
            postNewTicketToDatabase(ticketName : ticketName)
        }else{
            postNewTicketToSheet(ticketName : ticketName)
        }
    }
    
    func postNewTicketToSheet(ticketName : String){
        networkController.postToSheet(params: ["command": "postNewTicket",
                                        "ticketSerialNumber" :"\(listPageM.ticketSerialNumber)",
                                        "ticketName": ticketName,
                                        "ticketDate": today],
                               callBack: { [self]
                                (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("added")
                                        let newTicket = UpcomingTicket(name: ticketName, date:dateFormatter.string(from: today))
                                        newTicket.id = listPageM.ticketSerialNumber
                                        listPageM.ticketSerialNumber += 1
                                        upcomingTicketList.value.append(newTicket)
                                        
                                    }else{
                                        getDataSuccessful.value = false
                                        print("cannot add it", jsonData?.debugDescription)
                                    }
                                }else{
                                    getDataSuccessful.value = false
                                    print("cannot add it", jsonData?.debugDescription)
                                }
                               })
    }
    
    func postNewTicketToDatabase(ticketName : String){
        networkController.postToDatabase(api: "postNewTicket",
                                         params: ["ticketName": ticketName],
                                         callBack: { [self] (jsonData) in
                                            let id = jsonData![0]["id"].int
                                            let name = jsonData![0]["content"].string
                                            let date = jsonData![0]["create_at"].string!.split(separator: "T")[0]
                                            print("added", ticketName)
                                            let newTicket = UpcomingTicket(name: name!, date: String(date))
                                            newTicket.id = id!
//                                            listPageM.ticketSerialNumber += 1
                                            upcomingTicketList.value.insert(newTicket, at : 0)
                                         })
    }
    
    func checkTicket(index : Int, ticketSerialNumber : String){
        if isDatabaseAlive(){
            checkTicketFromDatabase(index : index, ticketSerialNumber : ticketSerialNumber)
        }else{
            checkTicketFromSheet(index : index, ticketSerialNumber : ticketSerialNumber)
        }
    }
    
    func checkTicketFromSheet(index : Int, ticketSerialNumber : String){
        networkController.postToSheet(params: ["command" : "checkTicket",
                                        "ticketSerialNumber" : ticketSerialNumber],
                               callBack: { [self] (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("checked")
                                        postTicketList.value.insert(PostTicket(name: upcomingTicketList.value[index].name!, date: dateFormatter.string(from: today)), at: 0)
                                        upcomingTicketList.value.remove(at: index)
                                    }else{
                                        getDataSuccessful.value = false
                                        print("cannot check it", jsonData?.debugDescription)
                                    }
                                }else{
                                    getDataSuccessful.value = false
                                    print("cannot check it", jsonData?.debugDescription)
                                }        })
    }
    
    func checkTicketFromDatabase(index : Int, ticketSerialNumber : String){
        networkController.postToDatabase(api: "checkTicket",
                                         params: ["id" : ticketSerialNumber],
                                         callBack: { [self] (jsonData) in
                                            print("checked id", ticketSerialNumber)
                                            let name = jsonData![0]["content"].string
                                            let date = jsonData![0]["create_at"].string!.split(separator: "T")[0]
                                            postTicketList.value.insert(PostTicket(name: name!, date: String(date)), at: 0)
                                            upcomingTicketList.value.remove(at: index)
                                         })
    }
    
    func deleteTicket(ticketSerialNumber : String, index : Int){
        if isDatabaseAlive(){
            deleteTicketFromDatabase(ticketSerialNumber : ticketSerialNumber, index : index)
        }else{
            deleteTicketFromSheet(ticketSerialNumber : ticketSerialNumber, index : index)
        }
    }
    
    func deleteTicketFromSheet(ticketSerialNumber : String, index : Int){
        networkController.postToSheet(params: ["command" : "deleteTicket",
                                        "ticketSerialNumber" : ticketSerialNumber],
                               callBack: { [self] (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("deleted")
                                        upcomingTicketList.value.remove(at: index)
                                    }else{
                                        getDataSuccessful.value = false
                                        print("cannot delete it", jsonData?.debugDescription)
                                    }
                                }else{
                                    getDataSuccessful.value = false
                                    print("cannot delete it", jsonData?.debugDescription)
                                }        })
    }
    
    func deleteTicketFromDatabase(ticketSerialNumber : String, index : Int){
        networkController.postToDatabase(api: "deleteTicket",
                                         params: ["id" : ticketSerialNumber],
                                         callBack: { [self] (jsonData) in
                                            upcomingTicketList.value.remove(at: index)
                                         })
    }
}
