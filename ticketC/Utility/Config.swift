//
//  Config.swift
//  ticketC
//
//  Created by Billy W on 2020/11/22.
//

import Foundation
import AVFoundation

enum Style : Int, Codable{
    case defaultStyle = 0
    case xmasStyle = 1
    case minionStyle = 2
    case none = -1
}

class Config : NSObject{
    
    public static let NO_ERROR = 0
    public static let ERROR_NO_DATA = 1
    public static let ERROR_NO_CONNECTION = 2
    public static let WAITING_FOR_CONNECTION = 3
    public static let sharedInstance = Config()
    public let tools = Tools.sharedInstance
    public var currentStyle : LiveData<Style> = LiveData(.none)
    private var secondTimer : Timer?
    public var styleColor : BaseStyleColor? = nil
    public var isTestMode = true
    public var embargo = true
    public var audioPlayer = AVAudioPlayer()
    public var currentUser : String?
    public var objectUser : String?
    public var currentArticles : String?
    public var dateStr : String?
    
    override init(){
        super.init()
        initStyle()
        checkEmbargo()
        setUsers()
        getDateStr()
    }
    
    func setUsers(){
        if isTestMode{
            currentUser = "testA"
            objectUser = "testB"
            currentArticles = "test"
        }else{
            currentUser = "Christina"
            objectUser = "Billy"
            currentArticles = "real"
        }
    }
    
    func initStyle(){
        currentStyle.value = getStyle()
        switch currentStyle.value {
        case .defaultStyle:
            styleColor = DefaultStyleColor()
        case .xmasStyle:
            styleColor = XmasStyleColor()
        case .minionStyle:
            styleColor = MinionStyleColor()
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
    
    func setMusic(){
        if audioPlayer.isPlaying{
            audioPlayer.pause()
            audioPlayer.stop()
            print("should stop")
        }
        var AssortedMusics = NSURL()
        switch currentStyle.value {
        case .defaultStyle:
            AssortedMusics = NSURL(fileURLWithPath: Bundle.main.path(forResource: "October_time to love", ofType: "mp3")!)
        case .xmasStyle:
            AssortedMusics = NSURL(fileURLWithPath: Bundle.main.path(forResource: "That s Christmas to Me - Pentatonix", ofType: "mp3")!)
        case .minionStyle:
            AssortedMusics = NSURL(fileURLWithPath: Bundle.main.path(forResource: "minions-banana", ofType: "mp3")!)
        case .none:
            print("no music?")
        }
        audioPlayer = try! AVAudioPlayer(contentsOf: AssortedMusics as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    func getDateStr(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.string(from: Date())
        dateStr = date
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
