//
//  ViewController.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit
import SwiftyJSON
import Alamofire

class ListPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var networkController = NetworkController()
    
    var refreshControl = UIRefreshControl()
    var ticketSerialNumber = 0
    var newTicketName = ""
    var maxTicketNum = 3
    var quota = 0
    
    @IBOutlet weak var label_ticket_quota: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    private var userDefaults = UserDefaults.standard
    private var postTicketList = [PostTicket]()
    private var upcomingTicketList = [UpcomingTicket]()
    let today = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTicketData()
    }
    
    func initData(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = true
        refreshControl.addTarget(self, action: #selector(getTicketData), for: UIControl.Event.valueChanged)
        
        dateFormatter.dateFormat = "YYYY/MM/dd"
        registerNib()
        setDismissKeyboardListener()
    }
    
    func registerNib(){
        self.tableView.register(UINib(nibName: "NewTicketTVC", bundle: nil), forCellReuseIdentifier: "NewTicketTVC")
        self.tableView.register(UINib(nibName: "PostTVC2", bundle: nil), forCellReuseIdentifier: "PostTVC2")
        self.tableView.register(UINib(nibName: "UpcomingTVC", bundle: nil), forCellReuseIdentifier: "UpcomingTVC")
    }
    
    func setDismissKeyboardListener(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
    func hideLoader(){
        loader.isHidden = true
        refreshControl.endRefreshing()
    }
    
    func updateQuota(){
        quota = maxTicketNum - upcomingTicketList.count - postTicketList.count
        if quota == 0{
            label_ticket_quota.isHidden = true
        }else{
            label_ticket_quota.isHidden = false
            label_ticket_quota.text = "還有"+"\(quota)"+"張可以填寫唷"
        }
    }
    
    @objc func getTicketData(){
        loader.isHidden = false
        postTicketList.removeAll()
        upcomingTicketList.removeAll()
        tableView.reloadData()
        networkController.post(params: ["command": "getTickets"], callBack: { [self]
            (jsonData) in
            if jsonData!["status"].int == 200{
            if jsonData != nil{
                let data = jsonData!["data"]
                if data["ticketNum"].string == nil{
                    maxTicketNum = data["ticketNum"].int!
                }else{
                    maxTicketNum = Int(data["ticketNum"].string!)!
                }
                let tickets = data["tickets"].array
                if !tickets!.isEmpty{
                    ticketSerialNumber = tickets!.count
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
                            postTicketList.append(ticket)
                        }else{
                            let ticket = UpcomingTicket(name: ticketName!, date: String(ticketDate))
                            ticket.id = ticketSerialNumber!
                            upcomingTicketList.append(ticket)
                        }
                    }
                }
            }
            tableView.reloadData()
            updateQuota()
            hideLoader()
            }else{
                loader.isHidden = true
                errorDialog()
                print("error", jsonData?.debugDescription)
            }
        })
    }
    
    func postNewTicket(ticketSerialNumber : String, ticketName : String, ticketDate : String){
        networkController.post(params: ["command": "postNewTicket",
                                        "ticketSerialNumber" :ticketSerialNumber,
                                        "ticketName": ticketName,
                                        "ticketDate": ticketDate],
                               callBack: { [self]
                                (jsonData) in
                                if jsonData != nil{
                                    if jsonData!["status"].int == 200{
                                        print("added")
                                        
                                        let newTicket = UpcomingTicket(name: newTicketName, date:dateFormatter.string(from: today))
                                        newTicket.id = self.ticketSerialNumber
                                        self.ticketSerialNumber += 1
                                        upcomingTicketList.append(newTicket)
                                        tableView.reloadData()
                                        updateQuota()
                                        
                                        saveData()
                                        loader.isHidden = true
                                        
                                    }else{
                                        loader.isHidden = true
                                        errorDialog()
                                        print("cannot add it", jsonData?.debugDescription)
                                    }
                                }else{
                                    errorDialog()
                                    print("cannot add it", jsonData?.debugDescription)
                                    loader.isHidden = true
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
                                        
                                        postTicketList.append(PostTicket(name: upcomingTicketList[index].name!, date: dateFormatter.string(from: today)))
                                        upcomingTicketList.remove(at: index)
                                        tableView.reloadData()
                                        updateQuota()
                                        
                                        saveData()
                                        loader.isHidden = true
                                    }else{
                                        loader.isHidden = true
                                        errorDialog()
                                        print("cannot check it", jsonData?.debugDescription)
                                    }
                                }else{
                                    loader.isHidden = true
                                    errorDialog()
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
                                        upcomingTicketList.remove(at: index)
                                        tableView.reloadData()
                                        updateQuota()
                                        loader.isHidden = true
                                        saveData()
                                    }else{
                                        loader.isHidden = true
                                        errorDialog()
                                        print("cannot delete it", jsonData?.debugDescription)
                                    }
                                }else{
                                    errorDialog()
                                    loader.isHidden = true
                                    print("cannot delete it", jsonData?.debugDescription)
                                }        })
    }
    
    @objc func showAddDialog(_ sender : UIButton){
        let controller = UIAlertController(title: "確定新增" + newTicketName + "嗎？", message: "一但新增將無法修改，確定新增嗎？", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "新增", style: .default, handler: { [self] _ in
            loader.isHidden = false
            postNewTicket(ticketSerialNumber : "\(ticketSerialNumber)", ticketName: newTicketName, ticketDate: dateFormatter.string(from: today))
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.view.tintColor = UIColor.systemIndigo
        present(controller, animated: true, completion: nil)
        
    }
    
    func errorDialog(){
        let controller = UIAlertController(title: "錯誤", message: "網路不穩定或無法獲取資料，建議重新載入，或重新開網路連線再嘗試喔！", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好喔！", style: .default, handler: nil)
        controller.addAction(okAction)
        controller.view.tintColor = UIColor.systemIndigo
        present(controller, animated: true, completion: nil)
    }
    
    @objc func showCheckDialog(_ sender : UIButton){
        if lessThanMaxTicketNum(){
            let controller = UIAlertController(title: "確認使用：" + upcomingTicketList[sender.tag-1].name! + "嗎？", message: "一張兌換券僅能使用一次，請謹慎使用唷！", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "我就要用！", style: .default, handler: { [self] _ in
                
                loader.isHidden = false
                for i in 0 ..< upcomingTicketList.count{
                    if self.upcomingTicketList[i].index == sender.tag{
                        checkTicket(index: upcomingTicketList[i].index! - 1, ticketSerialNumber: "\(upcomingTicketList[i].id!)")
                        break
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "痾...算了", style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            controller.view.tintColor = UIColor.systemIndigo
            present(controller, animated: true, completion: nil)
        }else{
            let controller = UIAlertController(title: "確認使用：" + upcomingTicketList[sender.tag].name! + "嗎？", message: "一張兌換券僅能使用一次，請謹慎使用唷！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "就是要用！", style: .default, handler: { [self] _ in
                
                loader.isHidden = false
                for i in 0 ..< upcomingTicketList.count{
                    if upcomingTicketList[i].index == sender.tag{
                        checkTicket(index: upcomingTicketList[i].index!, ticketSerialNumber: "\(upcomingTicketList[i].id!)")
                        break
                    }
                }
                
            })
            
            let cancelAction = UIAlertAction(title: "沒有！開玩笑的啦", style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            controller.view.tintColor = UIColor.systemIndigo
            present(controller, animated: true, completion: nil)
        }
    }
    
    func showDialog(section: Int, index: Int){
        var controller = UIAlertController()
        switch section {
        case 0:
            controller = UIAlertController(title: upcomingTicketList[index].name!, message: upcomingTicketList[index].date!+"新增的\""+upcomingTicketList[index].name!+"\"正在等你兌換呢！", preferredStyle: .alert)
        case 1:
            controller = UIAlertController(title: postTicketList[index].name!, message: postTicketList[index].date!+"新增的\""+postTicketList[index].name!+"\"已經對換過囉！", preferredStyle: .alert)
        default:
            break
        }
        let okAction = UIAlertAction(title: "好喔！", style: .default, handler: nil)
        controller.addAction(okAction)
        controller.view.tintColor = UIColor.systemIndigo
        present(controller, animated: true, completion: nil)
    }
    
    @objc func newTicketNameChanged(_ sender:UITextField){
        newTicketName = sender.text!
    }
    
    //tableView
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "等你兌換的好東西："+"\(upcomingTicketList.count)"
        case 1:
            return "已兌換的好東西："+"\(postTicketList.count)"
        default:
            print("header Out of Range")
            return ""
        }
    }
    
    //change the size of header section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    //change the style of header section
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 25)
        header.textLabel?.frame = header.frame
        header.layer.borderWidth = 0.5
        header.layer.borderColor = UIColor.white.cgColor
        header.layer.borderColor = UIColor(named: "main tone")?.cgColor
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.systemIndigo
        header.textLabel?.textAlignment = .left
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if postTicketList.count == 0{
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("numberOfRowsInSection")
        switch section {
        case 0:
            if lessThanMaxTicketNum(){
                print("??? numberofrow1", upcomingTicketList.count , postTicketList.count , maxTicketNum)
                return upcomingTicketList.count + 1
            }
            print("??? numberofrow2", upcomingTicketList.count , postTicketList.count , maxTicketNum)
            return upcomingTicketList.count
        case 1:
            return postTicketList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        switch indexPath.section {
        case 0:
            if(indexPath.row == 0 && lessThanMaxTicketNum()){
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewTicketTVC", for: indexPath) as! NewTicketTVC
                //                cell.delegate = self
                cell.btn_confirm.addTarget(self, action: #selector(showAddDialog(_:)), for: .touchDown)
                cell.tf_ticket_name.addTarget(self, action: #selector(newTicketNameChanged(_:)), for: .editingChanged)
                return cell
            }else if indexPath.row != 0 && lessThanMaxTicketNum()
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                //                cell.delegate = self
                cell.btn_check.tag = indexPath.row
                upcomingTicketList[indexPath.row-1].index = indexPath.row
                cell.ticket_name.text = upcomingTicketList[indexPath.row-1].name
                cell.added_date.text = upcomingTicketList[indexPath.row-1].date?.description
                cell.btn_check.addTarget(self, action: #selector(showCheckDialog(_:)), for: .touchDown)
                return cell
            }else if upcomingTicketList.count + postTicketList.count >= maxTicketNum{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                //                cell.delegate = self
                newTicketName = ""
                cell.btn_check.tag = indexPath.row
                upcomingTicketList[indexPath.row].index = indexPath.row
                cell.ticket_name.text = upcomingTicketList[indexPath.row].name
                cell.added_date.text = upcomingTicketList[indexPath.row].date?.description
                cell.btn_check.addTarget(self, action: #selector(showCheckDialog(_:)), for: .touchUpInside)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTVC2", for: indexPath) as! PostTVC2
            cell.ticket_name.text = postTicketList[indexPath.row].name
            cell.added_date.text = postTicketList[indexPath.row].date?.description
            return cell
        default:
            print("no such section in tableView")
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("selected")
            switch indexPath.section {
            case 0:
                if (indexPath.row != 0){
                    if lessThanMaxTicketNum(){
                        showDialog(section: indexPath.section, index: indexPath.row-1)
                    }else{
                        showDialog(section: indexPath.section, index: indexPath.row)
                    }
                }
            case 1:
                showDialog(section: indexPath.section, index: indexPath.row)
            default:
                print("no such device")
            }
            // 取消 cell 的選取狀態
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                if lessThanMaxTicketNum(){
                    if indexPath.row == 0 {
                        let controller = UIAlertController(title: "ah?", message: "尼確定要刪掉新增兌換券的機會嗎？", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "偶按錯了！哇哈哈哈", style: .default, handler: nil)
                        controller.addAction(okAction)
                        controller.view.tintColor = UIColor.systemIndigo
                        present(controller, animated: true, completion: nil)
                        break
                    }
                    deleteTicket(ticketSerialNumber: "\(upcomingTicketList[indexPath.row-1].id!)", index: indexPath.row-1)
                }else{
                    deleteTicket(ticketSerialNumber: "\(upcomingTicketList[indexPath.row].id!)", index: indexPath.row)
                }
                loader.isHidden = false
            case 1:
                let controller = UIAlertController(title: "尼要刪掉 " + newTicketName+"？", message: "這是我們的回憶阿尼怎麼忍心", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "偶錯了", style: .default, handler: nil)
                controller.addAction(okAction)
                controller.view.tintColor = UIColor.systemIndigo
                present(controller, animated: true, completion: nil)
            default:
                print("no such row")
            }
        } else if editingStyle == .none{
            print("???")
        }
    }
    
    func getDataFromUserDefault(){
        do {
            if let data =  userDefaults.data(forKey:"postTicketList") {
                let res = try JSONDecoder().decode([PostTicket].self,from:data)
                postTicketList = res
            } else {
                print("No postTicketList")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  userDefaults.data(forKey:"upcomingTicketList") {
                let res = try JSONDecoder().decode([UpcomingTicket].self,from:data)
                upcomingTicketList = res
            } else {
                print("No upcomingTicketList")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  userDefaults.data(forKey:"maxTicketNum") {
                let res = try JSONDecoder().decode(Int.self,from:data)
                maxTicketNum = res
            } else {
                print("No maxTicketNum")
            }
        }
        catch { print(error) }
        
        do {
            if let data =  userDefaults.data(forKey:"ticketSerialNumber") {
                let res = try JSONDecoder().decode(Int.self,from:data)
                ticketSerialNumber = res
            } else {
                print("No ticketSerialNumber")
            }
        }
        catch { print(error) }
            
    }
    
    func saveData(){
        do {
            let res = try JSONEncoder().encode(postTicketList)
            userDefaults.set(res,forKey: "postTicketList")
        }
        catch { print(error) }
        
        do {
            let res = try JSONEncoder().encode(upcomingTicketList)
            userDefaults.set(res,forKey: "upcomingTicketList")
        }
        catch { print(error) }
        
        do {
            let res = try JSONEncoder().encode(maxTicketNum)
            userDefaults.set(res,forKey: "maxTicketNum")
        }
        catch { print(error) }
        
        
        do {
            let res = try JSONEncoder().encode(ticketSerialNumber)
            userDefaults.set(res,forKey: "ticketSerialNumber")
        }
        catch { print(error) }
        
    }
    
    func lessThanMaxTicketNum() -> Bool{
        return upcomingTicketList.count + postTicketList.count < maxTicketNum
    }
}

