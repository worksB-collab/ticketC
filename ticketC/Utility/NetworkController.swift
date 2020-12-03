//
//  NetworkController.swift
//  ticketC
//
//  Created by Billy W on 2020/10/8.
//

import Foundation
import SwiftyJSON
import Alamofire

class NetworkController : NSObject{
    
    static let sharedInstance = NetworkController()
    let urlSheet = "https://script.google.com/macros/s/AKfycbymy1zuwcuPkconHCCRsD5h8UOun2tofuTHh5SAQZD3F4CTxeM/exec"
    let urlDatabase = "http://34.68.241.191:3000/"
    var isDatabaseAlive : Bool?
    var alamofireManager : Alamofire.Session!
    let tools = Tools.sharedInstance
    
    override init(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        alamofireManager = Alamofire.Session(configuration: configuration)
    }
    
    
    func getFromDatabase(api: String, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlDatabase + api, method: .get, headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                (response) in
                switch response.result{
                case .success(_):
                    if response.data!.isEmpty{
                        print("no data")
                    }
                    let jsonData = try! JSON(data: response.data!)
                    print("connection successful", response.result)
                    callBack?(jsonData)
                case .failure(_):
                    print("connection failure", response.result)
                    callBack?(nil)
                    
                }
            }
    }
    
    func postToDatabase(api: String, params: Dictionary<String, Any>, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlDatabase + api, method: .post, parameters: params,headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                (response) in
                switch response.result{
                case .success(_):
                    if response.data!.isEmpty{
                        print("no data")
                    }
                    let jsonData = try! JSON(data: response.data!)
                    callBack?(jsonData)
                case .failure(_):
                    print(response.result)
                    callBack?(nil)
                    
                }
            }
    }
    
    func postToSheet(params: Dictionary<String, Any>, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlSheet, method: .post, parameters: params,headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                (response) in
                switch response.result{
                case .success(_):
                    if response.data!.isEmpty{
                        print("no data")
                    }
                    let jsonData = try! JSON(data: response.data!)
                    callBack?(jsonData)
                case .failure(_):
                    print(response.result)
                    callBack?(nil)
                    
                }
            }
    }
    
    
}

