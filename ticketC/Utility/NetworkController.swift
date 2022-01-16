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
    let urlSheet = "https://script.google.com/macros/s/AKfycbx5S2fcgVwbFG2eRJNGu7j_UrSgKNcZT99kwlXj1j_LMtYlaMAavXv-uGRw3gCtkKWw/exec"
    let urlDatabase = "http://34.68.241.191:3000/"
    var isDatabaseAlive : Bool?
    var alamofireManager : Alamofire.Session!
    let tools = Tools.sharedInstance
    var connectionError : LiveData<Int> = LiveData(0)
    
    override init(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        alamofireManager = Alamofire.Session(configuration: configuration)
    }
    
    
    func getFromDatabase(api: String, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlDatabase + api, method: .get, headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                [self] (response) in
                
                var statusCode = response.response?.statusCode
                if let error = response.error {
                    statusCode = error._code // statusCode private
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")

                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                            statusCode = code
                        case .customValidationFailed(error: let _):
                            print("customValidationFailed")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        // statusCode = 3840 ???? maybe..
                    default:break
                    }
                    print("Underlying error: \(error.underlyingError)")
                } else if let error = response.error as? URLError {
                    print("URLError occurred: \(error)")
                } else {
                    print("Unknown error: \(response.error)")
                }

                print(statusCode) // the status code
                
                switch response.result{
                case .success(_):
                    if response.data!.isEmpty{
                        print("no data")
                    }
                    let jsonData = try! JSON(data: response.data!)
                    print("connection successful", response.result)
                    if !jsonData.isEmpty{
                        callBack?(jsonData)
                    }else{
                        print("connection failed")
                        connectionError.value = Config.ERROR_NO_CONNECTION
                    }
                case .failure(_):
                    print("connection failure", response.result)
                    connectionError.value = Config.ERROR_NO_CONNECTION
                }
                connectionError.value = Config.NO_ERROR
            }
    }
    
    func postToDatabase(api: String, params: Dictionary<String, Any>, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlDatabase + api, method: .post, parameters: params,headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                [self] (response) in
                
                
                
                var statusCode = response.response?.statusCode
                if let error = response.error {
                    statusCode = error._code // statusCode private
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")

                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                            statusCode = code
                        case .customValidationFailed(error: let _):
                            print("customValidationFailed")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        // statusCode = 3840 ???? maybe..
                    default:break
                    }
                    print("Underlying error: \(error.underlyingError)")
                } else if let error = response.error as? URLError {
                    print("URLError occurred: \(error)")
                } else {
                    print("Unknown error: \(response.error)")
                }

                print(statusCode) // the status code
                
                switch response.result{
                case .success(_):
                    if response.data!.isEmpty{
                        print("no data")
                    }
                    let jsonData = try! JSON(data: response.data!)
                    print("connection successful", response.result)
                    if !jsonData.isEmpty{
                        callBack?(jsonData)
                    }else{
                        print("connection failed")
                        connectionError.value = Config.ERROR_NO_CONNECTION
                    }
                case .failure(_):
                    print("connection failure", response.result)
                    connectionError.value = Config.ERROR_NO_CONNECTION
                }
                connectionError.value = Config.NO_ERROR
                
            }
    }
    
    func postToSheet(params: Dictionary<String, Any>, callBack:((JSON?) -> ())?){
        alamofireManager.request(urlSheet, method: .post, parameters: params,headers: [:])
            .validate().validate(statusCode: 200 ..< 500).responseJSON{
                [self] (response) in
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
                connectionError.value = Config.NO_ERROR
            }
    }
    
    
}

