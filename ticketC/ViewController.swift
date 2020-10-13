//
//  ViewController.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit

class ListPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NewTicket{
    
    
    private var userDefaults = UserDefaults.standard
    private var postTicketList = [PostTicket]()
    private var upcomingTicketList = [UpcomingTicket]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }

    func getData(){
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
        
    }
    
    func saveData(key : String, value : [BaseTicket]){
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
    }
    
    //tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("numberOfRowsInSection")
        switch section {
        case 0:
            return upcomingTicketList.count + 1
        case 1:
            return postTicketList.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Upcoming Tickets"
        case 1:
            return "Post Tickets"
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
        header.textLabel?.textColor = UIColor(named: "Color-3")
        header.textLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 25)
        header.textLabel?.frame = header.frame
        header.layer.borderWidth = 0.5
        header.layer.borderColor = UIColor(named: "main tone")?.cgColor
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white
        header.textLabel?.textAlignment = .left
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt")

        tableView.tableFooterView = UIView()
        switch indexPath.section {
        case 0:
            if(indexPath.row == 0){
                _ = tableView.dequeueReusableCell(withIdentifier: "NewTicketTVC", for: indexPath) as! NewTicketTVC
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                cell.ticket_name.text = upcomingTicketList[indexPath.row-1].name
                cell.added_date.text = upcomingTicketList[indexPath.row-1].date?.description
                cell.btn_check.addTarget(self, action: #selector(showCheckDialog(_:)), for: .touchUpInside)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTVC", for: indexPath) as! PostTVC
            cell.ticket_name.text = postTicketList[indexPath.row].name
            cell.added_date.text = postTicketList[indexPath.row].date?.description
            return cell
        default:
            print("no such section in tableView")
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        switch indexPath.section {
        case 0:
            if (indexPath.row != 0){
                showDialog(section: indexPath.section, index: indexPath.row)
            }
        case 1:
            showDialog(section: indexPath.section, index: indexPath.row)
        default:
            print("no such device")
        }
    }
    
    
    @objc func showCheckDialog(_ sender : UIButton){
        
    }
    
    func showDialog(section : Int, index : Int){
        
    }
    
    func addNewTicket(ticketName: String) {
        let controller = UIAlertController(title: "已確認新增：" + ticketName, message: "太好啦！尼已經成功增加一張新的兌換券！要謹慎使用喔！", preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           controller.addAction(okAction)
           present(controller, animated: true, completion: nil)
    }
    

}

