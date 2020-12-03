//
//  Config.swift
//  ticketC
//
//  Created by Billy W on 2020/11/22.
//

import Foundation

enum Style : Int, Codable{
    case defaultStyle = 1
    case xmasStyle = 2
    case none = 0
}

class Config : NSObject{
    
    public static let ERROR_NO_DATA = 1
    public static let ERROR_NO_CONNECTION = 2
    public static let sharedInstance = Config()
    public var currentStyle : LiveData<Style> = LiveData(.none)
    public let tools = Tools.sharedInstance
    public var styleColor : BaseStyleColor? = nil
    public var embargo = true
    
    override init(){
        super.init()
        initStyle()
        checkEmbargo()
    }
    
    func initStyle(){
        print("should init first")
        currentStyle.value = getStyle()
        switch currentStyle.value {
        case .defaultStyle:
            styleColor = DefaultStyleColor()
        case .xmasStyle:
            styleColor = XmasStyleColor()
        case .none:
            currentStyle.value = .defaultStyle
            styleColor = DefaultStyleColor()
            saveStyle()
            print("no current style")
            break
        }
    }
    
    func setStyle(style : Style){
        currentStyle.value = style
        saveStyle()
        initStyle()
    }
    
    func checkEmbargo(){
        let data : Bool? = tools.read(name: "embargo")
        if data == nil{
            embargo = true
        }else{
            embargo = data!
        }
    }
    
    func getStyle() -> Style{
        return tools.read(name: "style")
    }
    
    func saveStyle(){
        tools.write(name: "style", data: currentStyle.value)
    }
}
