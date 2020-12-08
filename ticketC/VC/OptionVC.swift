//
//  OptionVC.swift
//  ticketC
//
//  Created by Billy W on 2020/11/22.
//

import UIKit

class OptionVC: BaseVC , UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{
    
    private let optionVM = OptionVM()
    private let optionArr : [String] = ["給寶貝的信", "更換主題", "關於", "登出"]
    private let themeArr : [String] = ["寶貝熊貓", "聖誕夜", "小小兵"]
    
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        registerNib()
        setStyle()
        setObserver()
    }
    
    override func setStyle(){
        view.backgroundColor = config.styleColor?.backgroundColor
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: config.styleColor?.titleColor]
        tableView.backgroundColor = config.styleColor?.backgroundColor
        tableView.separatorColor = config.styleColor?.titleColor
        tableView.reloadData()
        tabBarController?.tabBar.barTintColor = config.styleColor?.titleColor
        tabBarController?.tabBar.tintColor = config.styleColor?.secondColor
        switch config.currentStyle.value {
        case .defaultStyle:
            img_icon.image = UIImage(named: "pandaB")
        case .xmasStyle:
            img_icon.image = UIImage(named: "christmas-tree")
        case .birthdayStyle:
            img_icon.image = UIImage(named: "minion11")
        case .none:
            print("no style to apply")
        }
    }
    
    func registerNib(){
        self.tableView.register(UINib(nibName: "OptionTVC", bundle: nil), forCellReuseIdentifier: "OptionTVC")
    }
    
    func showThemePicker(){
        //初始化UIPickerView
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        //设置选择框的默认值
        pickerView.selectRow(config.currentStyle.value.rawValue, inComponent: 0, animated: true)
        //把UIPickerView放到alert里面（也可以用datePick）
        let alertController:UIAlertController = UIAlertController(title: "選擇主題", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let width = view.frame.width;
//        let height = alertController.view.frame.height*2/3;
        pickerView.frame = CGRect(x: -10, y: 0, width: width, height: 250)
        alertController.view.addSubview(pickerView)
        alertController.addAction(UIAlertAction(title: "確定", style: .default){
            [self]_ in
            switch themeArr[pickerView.selectedRow(inComponent: 0)]{
            case "寶貝熊貓":
                config.setStyle(style: .defaultStyle)
            case "聖誕夜":
                config.setStyle(style: .xmasStyle)
            case "小小兵":
                config.setStyle(style: .birthdayStyle)
            default:
                print("selection error")
            }
            let tbc = self.tabBarController as! TabBarC
            tbc.setSecondTimer()
            setStyle()
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel,handler:nil))
        alertController.view.tintColor = config.styleColor?.mainColor
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showBirthdayText(){
        
    }
    
    func goToInstructionPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InstructionVC") as! InstructionVC
        present(vc,animated: true,completion: nil)
    }
    
    func checkIfLogout(){
        let controller = UIAlertController(title: "尼確定要登出嗎？", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "沒錯", style: .default, handler: {
        [self] _ in
            goBack()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.view.tintColor = config.styleColor?.mainColor
        present(controller, animated: true, completion: nil)
    }
    
    func goBack(){
        optionVM.saveCheckedLogin(data: false)
        view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if config.embargo{
            return optionArr.count - 1
        }
        return optionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        if config.embargo{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTVC", for: indexPath) as! OptionTVC
            cell.lb_name.text = optionArr[indexPath.row + 1]
            cell.setStyle()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTVC", for: indexPath) as! OptionTVC
        cell.lb_name.text = optionArr[indexPath.row]
        cell.setStyle()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if config.embargo{
            switch indexPath.row {
            case 0:
                showThemePicker()
            case 1:
                goToInstructionPage()
            case 2:
                checkIfLogout()
            default:
                print("no such option")
                break
            }
        }else{
            switch indexPath.row {
            case 0:
                showBirthdayText()
            case 1:
                showThemePicker()
            case 2:
                goToInstructionPage()
            case 3:
                checkIfLogout()
            default:
                print("no such option")
                break
            }
        }
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if config.embargo{
            return themeArr.count - 1
        }
        return themeArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themeArr[row]
    }
    
}
