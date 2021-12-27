//
//  ViewController.swift
//  ticketC
//
//  Created by Billy W on 2020/9/28.
//

import UIKit
import SwiftyJSON
import Alamofire

class ListPageVC: BaseVC, UITableViewDelegate, UITableViewDataSource{
    
    private let dateFormatter = DateFormatter()
    private let refreshControl = UIRefreshControl()
    private let listPageVM = ListPageVM()
    private var newTicketName = ""
    private var secondCount = 0
    
    @IBOutlet weak var sc_section: UISegmentedControl!
    @IBOutlet weak var label_ticket_quota: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var postTicketList = [PostTicket]()
    private var upcomingTicketList = [UpcomingTicket]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setObserver()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        setLocalizedStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTicketData()
        setStyle()
    }
    
    override func setStyle(){
        view.backgroundColor = config.styleColor?.backgroundColor
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: config.styleColor?.titleColor]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: config.styleColor?.titleColor]
        sc_section.selectedSegmentTintColor = config.styleColor?.mainColor
        sc_section.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: config.styleColor?.btnTextColor] , for: .normal)
        label_ticket_quota.textColor = config.styleColor?.titleColor
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = config.styleColor?.titleColor
        tabBarController?.tabBar.barTintColor = config.styleColor?.titleColor
        tabBarController?.tabBar.tintColor = config.styleColor?.secondColor
    }
    
    func initData(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        refreshControl.addTarget(self, action: #selector(getTicketData), for: UIControl.Event.valueChanged)
        
        registerNib()
        setDismissKeyboardListener()
    }
    
    func setObserver(){
        listPageVM.postTicketList.observe{ [self] (data) in
            postTicketList = data
            tableView.reloadData()
            hideLoader()
        }
        listPageVM.upcomingTicketList.observe{ [self] (data) in
            upcomingTicketList = data
            tableView.reloadData()
            hideLoader()
        }
        listPageVM.getDataSuccessful.observe{ [self] (isSuccessful) in
            if !isSuccessful{
                loader.isHidden = true
                errorDialog()
                print("isSuccessful")
            }
        }
        config.currentStyle.observe{ [self] _ in
            setStyle()
        }
        listPageVM.connectionError.observe{ [self] (error) in
            switch error{
            case Config.NO_ERROR:
                break
            case Config.ERROR_NO_DATA:
                errorDialog()
                print("error1")
            case Config.ERROR_NO_CONNECTION:
                errorDialog()
                print("error2")
            case Config.WAITING_FOR_CONNECTION:
//                setSecondTimer()
                print("error3")
            default:
                break
            }
        }
        listPageVM.quota.observe{ [self] (data) in
            updateQuota(quota: data)
        }
        sc_section.addTarget(self, action: #selector(onChange), for: .valueChanged)
    }
    
    func setLocalizedStrings(){
        sc_section.setTitle("我的兌換券".localized, forSegmentAt: 0)
        sc_section.setTitle("寶貝的兌換券".localized, forSegmentAt: 1)
        tabBarItem.title = "兌換券".localized
        navigationController?.navigationItem.title = "兌換券".localized
        navigationItem.title = "兌換券".localized
        tabBarController?.tabBar.items?[0].title = "兌換券".localized
        tabBarController?.tabBar.items?[1].title = "選項".localized
    }
    
    @objc func onChange(sender: UISegmentedControl) {
        // 印出選到哪個選項 從 0 開始算起
        print(sender.selectedSegmentIndex)

        // 印出這個選項的文字
        print(
            sender.titleForSegment(
                at: sender.selectedSegmentIndex))
        
        getTicketData()
    }
    
    @objc func secondTimerFunc(){
        
        if connectionError == Config.WAITING_FOR_CONNECTION{
            secondCount += 1
            if secondCount == 50{
            errorDialog()
//            stopSecondTimer()
            secondCount = 0
            }
        }
        
//        secondCount += 1
//        if config.currentStyle.value == .xmasStyle{
//            if getRandomNum(min: 0, max: 10) > 8.5{
//                generateCircle()
//            }
//            for i in snowArr{
//                let horizontalMove = Int(getRandomNum(min: -3, max: 3))
//                i.position = CGPoint(x: Int(i.position.x) - horizontalMove, y: (Int(i.position.y) + 4) + Int(i.lineWidth) - abs(horizontalMove))
//                if i.position.y >= view.frame.height + 10 {
//                    i.removeFromSuperlayer()
//                }
//            }
//        }else{
//            removeSnow()
//        }
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
        tap.cancelsTouchesInView = false
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
    
    func updateQuota(quota : Int){
        if quota <= 0{
            label_ticket_quota.isHidden = true
        }else{
            label_ticket_quota.isHidden = false
            label_ticket_quota.text = "還有".localized + "\(quota)" + "張可以填寫唷".localized
        }
    }
    
    @objc func getTicketData(){
        loader.isHidden = false
        if sc_section.selectedSegmentIndex == 0{
            listPageVM.getTicketDataFromSheet(user: config.currentUser!)
        }else{
            listPageVM.getTicketDataFromSheet(user: config.objectUser!)
        }
    }
    
    @objc func showAddDialog(_ sender : UIButton){
        let controller = UIAlertController(title: "確定新增".localized + newTicketName + "嗎？".localized, message: "一但新增將無法修改，確定新增嗎？".localized, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "新增".localized, style: .default, handler: { [self] _ in
            loader.isHidden = false
            listPageVM.postNewTicketToSheet(ticketName: newTicketName, user: config.currentUser!)
        })
        
        let cancelAction = UIAlertAction(title: "取消".localized, style: .cancel, handler: nil)
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.view.tintColor = config.styleColor?.mainColor
        present(controller, animated: true, completion: nil)
        
    }
    
    func errorDialog(){
        loader.isHidden = true
        let controller = UIAlertController(title: "錯誤".localized, message: "網路不穩定或無法獲取資料，建議重新載入，或重新開網路連線再嘗試喔！".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好喔！".localized, style: .default, handler: nil)
        controller.addAction(okAction)
        controller.view.tintColor = config.styleColor?.mainColor
        present(controller, animated: true, completion: nil)
    }
    
    @objc func showCheckDialog(_ sender : UIButton){
        if lessThanMaxTicketNum(){
            let controller = UIAlertController(title: "確認使用：".localized + upcomingTicketList[sender.tag-1].name! + "嗎？".localized, message: "一張兌換券僅能使用一次，請謹慎使用唷！".localized, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "我就要用！".localized, style: .default, handler: { [self] _ in
                
                loader.isHidden = false
                for i in 0 ..< upcomingTicketList.count{
                    if self.upcomingTicketList[i].index == sender.tag{
                        listPageVM.checkTicketToSheet(index: upcomingTicketList[i].index! - 1, id: "\(upcomingTicketList[i].id!)", user: config.currentUser!)
                        break
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "痾...算了".localized, style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            controller.view.tintColor = config.styleColor?.mainColor
            present(controller, animated: true, completion: nil)
        }else{
            let controller = UIAlertController(title: "確認使用：".localized + upcomingTicketList[sender.tag].name! + "嗎？".localized, message: "一張兌換券僅能使用一次，請謹慎使用唷！".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "就是要用！".localized, style: .default, handler: { [self] _ in
                loader.isHidden = false
                for i in 0 ..< upcomingTicketList.count{
                    if upcomingTicketList[i].index == sender.tag{
                        listPageVM.checkTicketToSheet(index: upcomingTicketList[i].index!, id: "\(upcomingTicketList[i].id!)", user: config.currentUser!)
                        break
                    }
                }
                
            })
            
            let cancelAction = UIAlertAction(title: "沒有！開玩笑的啦".localized, style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            controller.view.tintColor = config.styleColor?.mainColor
            present(controller, animated: true, completion: nil)
        }
    }
    
    func showDialog(section: Int, index: Int){
        var controller = UIAlertController()
        switch section {
        case 0:
            controller = UIAlertController(title: upcomingTicketList[index].name!, message: upcomingTicketList[index].date!+"新增的\"".localized + upcomingTicketList[index].name!+"\"正在等你兌換呢！".localized, preferredStyle: .alert)
        case 1:
            controller = UIAlertController(title: postTicketList[index].name!, message: postTicketList[index].date!+"新增的\"".localized + postTicketList[index].name!+"\"已經對換過囉！".localized, preferredStyle: .alert)
        default:
            break
        }
        let okAction = UIAlertAction(title: "好喔！".localized, style: .default, handler: nil)
        controller.addAction(okAction)
        controller.view.tintColor = config.styleColor?.mainColor
        present(controller, animated: true, completion: nil)
    }
    
    @objc func newTicketNameChanged(_ sender:UITextField){
        newTicketName = sender.text!
    }
    
//    //tableView
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            if sc_section.selectedSegmentIndex == 0{
//                return "等你兌換的好東西：".localized + "\(upcomingTicketList.count)"
//            }
//            return "趕快兌換給寶貝的好東西：".localized + "\(upcomingTicketList.count)"
//        case 1:
//            if sc_section.selectedSegmentIndex == 0{
//                return "已兌換的好東西：".localized + "\(postTicketList.count)"
//            }
//            return "已兌換給寶貝的好東西：".localized + "\(postTicketList.count)"
//        default:
//            print("header Out of Range")
//            return ""
//        }
//    }
    
    //change the size of header section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    //change the style of header section
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.textColor = config.styleColor?.secondColor
//        header.textLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 25)
//        header.textLabel?.frame = header.frame
//        header.layer.borderWidth = 0.5
//        header.layer.borderColor = UIColor.white.cgColor
//        header.layer.borderColor = UIColor(named: "main tone")?.cgColor
//        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = config.styleColor?.titleColor
//        header.textLabel?.textAlignment = .left
//    }
    
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
            if sc_section.selectedSegmentIndex == 0{
                if lessThanMaxTicketNum(){
                    return upcomingTicketList.count + 1
                }
            }
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
            if sc_section.selectedSegmentIndex == 0{
                if(indexPath.row == 0 && lessThanMaxTicketNum()){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NewTicketTVC", for: indexPath) as! NewTicketTVC
                    //                cell.delegate = self
                    cell.btn_confirm.addTarget(self, action: #selector(showAddDialog(_:)), for: .touchDown)
                    cell.tf_ticket_name.addTarget(self, action: #selector(newTicketNameChanged(_:)), for: .editingChanged)
                    cell.setStyle()
                    return cell
                }else if indexPath.row != 0 && lessThanMaxTicketNum(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                    //                cell.delegate = self
                    cell.btn_check.tag = indexPath.row
                    upcomingTicketList[indexPath.row-1].index = indexPath.row
                    cell.ticket_name.text = upcomingTicketList[indexPath.row-1].name
                    cell.added_date.text = upcomingTicketList[indexPath.row-1].date?.description
                    cell.btn_check.addTarget(self, action: #selector(showCheckDialog(_:)), for: .touchDown)
                    cell.btn_check.isHidden = false
                    cell.setStyle()
                    return cell
                }else if upcomingTicketList.count + postTicketList.count >= listPageVM.getMaxTicketNum(){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                    newTicketName = ""
                    cell.btn_check.tag = indexPath.row
                    upcomingTicketList[indexPath.row].index = indexPath.row
                    cell.ticket_name.text = upcomingTicketList[indexPath.row].name
                    cell.added_date.text = upcomingTicketList[indexPath.row].date?.description
                    cell.btn_check.addTarget(self, action: #selector(showCheckDialog(_:)), for: .touchUpInside)
                    cell.btn_check.isHidden = false
                    cell.setStyle()
                    return cell
                }
            }else if sc_section.selectedSegmentIndex == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTVC", for: indexPath) as! UpcomingTVC
                cell.ticket_name.text = upcomingTicketList[indexPath.row].name
                cell.added_date.text = upcomingTicketList[indexPath.row].date?.description
                cell.btn_check.isHidden = true
                cell.setStyle()
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTVC2", for: indexPath) as! PostTVC2
            cell.ticket_name.text = postTicketList[indexPath.row].name
            cell.added_date.text = postTicketList[indexPath.row].date?.description
            cell.setStyle()
            return cell
        default:
            print("no such section in tableView")
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        if sc_section.selectedSegmentIndex == 0{
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
        }else if sc_section.selectedSegmentIndex == 1{
            showDialog(section: indexPath.section, index: indexPath.row)
        }
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if sc_section.selectedSegmentIndex == 0{
                switch indexPath.section {
                case 0:
                    if lessThanMaxTicketNum(){
                        if indexPath.row == 0 {
                            let controller = UIAlertController(title: "咦？".localized, message: "尼確定要刪掉新增兌換券的機會嗎？".localized, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "偶按錯了！哇哈哈哈".localized, style: .default, handler: nil)
                            controller.addAction(okAction)
                            controller.view.tintColor = config.styleColor?.mainColor
                            present(controller, animated: true, completion: nil)
                            break
                        }
                        listPageVM.deleteTicketToSheet(id: "\(upcomingTicketList[indexPath.row-1].id!)", index: indexPath.row-1, user: config.currentUser!)
                    }else{
                        listPageVM.deleteTicketToSheet(id: "\(upcomingTicketList[indexPath.row].id!)", index: indexPath.row, user: config.currentUser!)
                    }
                    loader.isHidden = false
                case 1:
                    let controller = UIAlertController(title: "尼要刪掉".localized + newTicketName+"嗎？".localized, message: "這是我們的回憶阿尼怎麼忍心".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "偶錯了".localized, style: .default, handler: nil)
                    controller.addAction(okAction)
                    controller.view.tintColor = config.styleColor?.mainColor
                    present(controller, animated: true, completion: nil)
                default:
                    print("no such row")
                }
            }else if sc_section.selectedSegmentIndex == 1{
                let controller = UIAlertController(title: "不可以！".localized, message: "這是我們的回憶阿尼怎麼忍心".localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "偶錯了".localized, style: .default, handler: nil)
                controller.addAction(okAction)
                controller.view.tintColor = config.styleColor?.mainColor
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: 80))
        headerView.backgroundColor = config.styleColor?.mainColor
        let titleLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: tableView.bounds.size.width, height: 80))
        switch section {
        case 0:
            if sc_section.selectedSegmentIndex == 0{
                titleLabel.text = "等你兌換的好東西：".localized + "\(upcomingTicketList.count)"
            }else if sc_section.selectedSegmentIndex == 1{
                titleLabel.text = "趕快兌換給寶貝的好東西：".localized + "\(upcomingTicketList.count)"
            }
        case 1:
            if sc_section.selectedSegmentIndex == 0{
                titleLabel.text = "已兌換的好東西：".localized + "\(postTicketList.count)"
            }else if sc_section.selectedSegmentIndex == 1{
                titleLabel.text = "已兌換給寶貝的好東西：".localized + "\(postTicketList.count)"
            }
        default:
            print("header Out of Range")
            titleLabel.text = ""
        }
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = config.styleColor?.btnTextColor
        titleLabel.backgroundColor = UIColor.clear
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func lessThanMaxTicketNum() -> Bool{
        return upcomingTicketList.count + postTicketList.count < listPageVM.getMaxTicketNum()
    }
}

