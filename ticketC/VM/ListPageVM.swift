//
//  ListPageVM.swift
//  ticketC
//
//  Created by Billy W on 2020/11/9.
//

import Foundation
class ListPageVM: BaseVM {
    
    private let dateFormatter = DateFormatter()
    private let networkController = NetworkController()
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
    
    
    func getTicketData(){
        listPageM.removeTicktList()
        networkController.post(params: ["command": "getTickets"], callBack: { [self]
            (jsonData) in
            if jsonData!["status"].int == 200{
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
                            listPageM.postTicketList.append(ticket)
                        }else{
                            let ticket = UpcomingTicket(name: ticketName!, date: String(ticketDate))
                            ticket.id = ticketSerialNumber!
                            listPageM.upcomingTicketList.append(ticket)
                        }
                    }
                }
            }
            }else{
                getDataSuccessful.value = false
                print("error", jsonData?.debugDescription)
            }
        })
    }
    
    func postNewTicket(ticketName : String, ticketDate : String){
        networkController.post(params: ["command": "postNewTicket",
                                        "ticketSerialNumber" :"\(listPageM.ticketSerialNumber)",
                                        "ticketName": ticketName,
                                        "ticketDate": ticketDate],
                               callBack: { [self]
                                (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("added")
                                        
                                        let newTicket = UpcomingTicket(name: ticketName, date:dateFormatter.string(from: Config.today))
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
    
    func checkTicket(index : Int, ticketSerialNumber : String){
        networkController.post(params: ["command" : "checkTicket",
                                        "ticketSerialNumber" : ticketSerialNumber],
                               callBack: { [self]
                                (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("checked")
                                        
                                        postTicketList.value.append(PostTicket(name: upcomingTicketList.value[index].name!, date: dateFormatter.string(from: Config.today)))
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
    
    func deleteTicket(ticketSerialNumber : String, index : Int){
        networkController.post(params: ["command" : "deleteTicket",
                                        "ticketSerialNumber" : ticketSerialNumber],
                               callBack: { [self]
                                (jsonData) in
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
    
    func getDataFromUserDefault(){
        do {
            if let data =  Config.userDefaults.data(forKey:"postTicketList") {
                let res = try JSONDecoder().decode([PostTicket].self,from:data)
                postTicketList.value = res
            } else {
                print("No postTicketList")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  Config.userDefaults.data(forKey:"upcomingTicketList") {
                let res = try JSONDecoder().decode([UpcomingTicket].self,from:data)
                upcomingTicketList.value = res
            } else {
                print("No upcomingTicketList")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  Config.userDefaults.data(forKey:"maxTicketNum") {
                let res = try JSONDecoder().decode(Int.self,from:data)
                listPageM.maxTicketNum = res
            } else {
                print("No maxTicketNum")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  Config.userDefaults.data(forKey:"ticketSerialNumber") {
                let res = try JSONDecoder().decode(Int.self,from:data)
                listPageM.ticketSerialNumber = res
            } else {
                print("No ticketSerialNumber")
            }
        }
        catch { print(error) }
            
    }
    
    func saveData(){
        do {
            let res = try JSONEncoder().encode(listPageM.postTicketList)
            Config.userDefaults.set(res,forKey: "postTicketList")
        }
        catch { print(error) }
        
        do {
            let res = try JSONEncoder().encode(listPageM.upcomingTicketList)
            Config.userDefaults.set(res,forKey: "upcomingTicketList")
        }
        catch { print(error) }
        
        do {
            let res = try JSONEncoder().encode(listPageM.maxTicketNum)
            Config.userDefaults.set(res,forKey: "maxTicketNum")
        }
        catch { print(error) }
        
        
        do {
            let res = try JSONEncoder().encode(listPageM.ticketSerialNumber)
            Config.userDefaults.set(res,forKey: "ticketSerialNumber")
        }
        catch { print(error) }
        
    }
}
