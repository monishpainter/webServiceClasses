//
//  WebService-Prefix.swift
//  SwiftDemo
//
//  Created by Monish Painter on 18/04/16.
//

import Foundation

public enum WSRequestType : Int {
    
    case Login
    case CodeVerfication
}

public enum RESPONSE_STATUS : NSInteger {
    case INVALID
    case VALID
    case MESSAGE
}

public enum WSRequestForIG : Int {
    case APIGetUserPost
    case APIGetInstaUserInfo
}

struct WebServicePrefix {

    static let Server_URL = "http://www.xyz.com"
    static let WS_PATH = "/restAPIs/"
    
    static func GetWSUrl(serviceType :WSRequestType) -> String
    {
        var serviceURl: NSString?
        switch serviceType
        {
        case .Login:
            serviceURl = "LoginValidate"
            break
     
        case .CodeVerfication:
            serviceURl = "codeVerfication"
            break
            
        }
        return "\(Server_URL)\(WS_PATH)\(serviceURl!)" as String
    }
    
}
