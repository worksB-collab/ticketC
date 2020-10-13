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
    
    let url = "https://script.google.com/macros/s/AKfycbymy1zuwcuPkconHCCRsD5h8UOun2tofuTHh5SAQZD3F4CTxeM/exec"
    var alamofireManager : Alamofire.Session!
    
    override init(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        alamofireManager = Alamofire.Session(configuration: configuration)
    }
    
    func post(params: Dictionary<String, Any>, callBack:((JSON?) -> ())?){
        
        alamofireManager.request(url, method: .post, parameters: params,headers: [:])
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

