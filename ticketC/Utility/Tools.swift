//
//  Tools.swift
//  ticketC
//
//  Created by Billy W on 2020/9/29.
//

import Foundation

class Tools {
    
    static let sharedInstance = Tools()
    private let userDefaults = UserDefaults.standard
    
    func write(name:String,data:Style){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    
    func read(name:String)-> Style{
        var data: Style = .none
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode(Style.self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }
    
    
    func write(name:String,data:Bool){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    
    func read(name:String)-> Bool?{
        var data: Bool?
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode(Bool.self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch {
            print("cannot read file", error)
            return data
            
        }
        return data
    }
    

}
