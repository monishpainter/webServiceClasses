//
//  HttpRequestManager.swift
//  SwiftDemo
//
//  Created by Monish Painter on 16/04/16.
//

import UIKit

import Alamofire
import SwiftyJSON

class HttpRequestManager {
    
    static let sharedInstance = HttpRequestManager()
    
    var responseObjectDic = Dictionary<String, AnyObject>()
    var URLString : String!
    var Message : String!
    
    private static var Manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            WebServicePrefix.Server_URL: .disableEvaluation
        ]
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
    // METHODS
    init() {}
    
    //MARK:- POST Request
    
    func postParameterRequest(endpointurl:String, reqParameters: [String: Any] ,responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String, _ rStaus:Bool) -> Void)
    {
        DLog( "URL : \(endpointurl) \nParam :\( reqParameters) ")
        ShowNetworkIndicator(xx: true)
        Alamofire.request(endpointurl, method: .post, parameters: reqParameters)
            .responseJSON { response in
                ShowNetworkIndicator(xx: false)
                
                DLog(response.request)  // original URL request
                DLog(response.response) // URL response
                DLog(response.data)     // server data
                DLog(response.result)   // result of response serialization
                
                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?, SOMETHING_WRONG,false)
                }
                else
                {
                    switch response.result {
                        
                    case .success(_):
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        
                        self.Message = responseJSON["message"] as! String
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        default :
                            break
                            
                        }
                        responseData(self.responseObjectDic, nil, self.Message, st)
                        
                    case .failure(let error):
                        print(error)
                        responseData(nil, error as NSError?, "Failed", false)
                    }
                }
        }
    }
    
    func postJSONRequest(endpointurl:String, jsonParameters:[String: Any], responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String?, _ rStaus:Bool) -> Void)
    {
       
        ShowNetworkIndicator(xx: true)
        DLog( "URL : \(endpointurl) \nParam :\( param) ")
        Alamofire.request(endpointurl, method: .post, parameters: jsonParameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                ShowNetworkIndicator(xx: false)
                
                DLog(response.request)  // original URL request
                DLog(response.response) // URL response
                DLog(response.data)     // server data
                DLog(response.result)   // result of response serialization
                
                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?, SOMETHING_WRONG,false)
                }
                else
                {
                    switch response.result {
                        
                    case .success(_):
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        if let mess = responseJSON["message"] as? String{
                            self.Message = mess
                        }
                        else{
                            self.Message = SOMETHING_WRONG
                        }
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        case RESPONSE_STATUS.MESSAGE.rawValue:
                           
                            runOnAfterTime(afterTime: 1.0, block: {
                                APP_CONTEXT.appRootController?.popToRootViewController(animated: true)
                                 NotificationCenter.default.post(name: .NOTI_INVALID_DEVICEID, object: self, userInfo: nil)
                            })
                            break
                            
                        default :
                            break
                            
                        }
                        responseData(self.responseObjectDic, nil, self.Message, st)
                        
                    case .failure(let error):
                        print(error)
                        responseData(nil, error as NSError?, "Failed", false)
                    }
                }
        }
    }
    
    //MARK:- GET Request1
    func getRequestWithoutParams(endpointurl:String,responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String, _ rStaus:Bool)  -> Void)
    {
        DLog( "URL : \(endpointurl)")
        ShowNetworkIndicator(xx: true)
        HttpRequestManager.Manager.request(endpointurl, method : .get)
            .responseJSON { response in
                ShowNetworkIndicator(xx: false)
                
                DLog(response.request)  // original URL request
                DLog(response.response) // URL response
                DLog(response.data)     // server data
                DLog(response.result)   // result of response serialization
                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?, SOMETHING_WRONG,false)
                }
                else
                {
                    switch response.result {
                        
                    case .success(_):
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        
                        self.Message = responseJSON["message"] as! String
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        default :
                            break
                            
                        }
                        responseData(self.responseObjectDic, nil, self.Message, st)
                        
                    case .failure(let error):
                        print(error)
                        responseData(nil, error as NSError?, "Failed", false)
                    }
                }
        }
    }
    
    //MARK:- GET Request
    func getRequest(endpointurl:String,parameters:[String: Any],responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String, _ rStaus:Bool) -> Void)
    {
        DLog( "URL : \(endpointurl) \nParam :\( parameters) ")
        ShowNetworkIndicator(xx: true)
        Alamofire.request(endpointurl , method: .get, parameters: parameters)
            .responseJSON { response in
                ShowNetworkIndicator(xx: false)
                
                DLog(response.request)  // original URL request
                DLog(response.response) // URL response
                DLog(response.data)     // server data
                DLog(response.result)   // result of response serialization
                
                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?, SOMETHING_WRONG,false)
                }
                else
                {
                    switch response.result {
                        
                    case .success(_):
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        
                        self.Message = responseJSON["message"] as! String
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        default :
                            break
                            
                        }
                        responseData(self.responseObjectDic, nil, self.Message, st)
                        
                    case .failure(let error):
                        print(error)
                        responseData(nil, error as NSError?, "Failed", false)
                    }
                }
        }
    }
    
    
    //MARK:- PUT Request
    func putRequest(endpointurl:String, jsonParameters:[String : Any],responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String, _ rStaus:Bool) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        Alamofire.request(endpointurl, method: .put, parameters: jsonParameters)
            .responseJSON { response in
                ShowNetworkIndicator(xx: false)
                
                DLog(response.request)  // original URL request
                DLog(response.response) // URL response
                DLog(response.data)     // server data
                DLog(response.result)   // result of response serialization
                
                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?, SOMETHING_WRONG,false)
                }
                else
                {
                    switch response.result {
                        
                    case .success(_):
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        
                        self.Message = responseJSON["message"] as! String
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        default :
                            break
                            
                        }
                        responseData(self.responseObjectDic, nil, self.Message, st)
                        
                    case .failure(let error):
                        print(error)
                        responseData(nil, error as NSError?, "Failed", false)
                    }
                }
        }
    }
    
    //MARK:- Download Image
    func createFolder(folderName:String)->URL
    {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as? String ?? ""
        let dataPath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(folderName).absoluteString
        if !FileManager.default.fileExists(atPath: dataPath) {
            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
        let fileURL = URL(string: dataPath)
        return fileURL!
    }
    
    func downloadFile( endpointurl : String ,responseData:@escaping (_ error:NSError?, _ rStaus:Bool) -> Void) {
        
        DLog("PDF URL : \(endpointurl)")
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileName = "pdf"
            var fileURL = self.createFolder(folderName: fileName)
            let fileNameURL = URL(string : "Report.pdf")
            fileURL = fileURL.appendingPathComponent((fileNameURL?.lastPathComponent)!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
        HttpRequestManager.Manager.download(endpointurl, to: destination).response(completionHandler: { (DefaultDownloadResponse) in
            if let _ = DefaultDownloadResponse.error
            {
                responseData(DefaultDownloadResponse.error! as NSError, false)
            }
            else
            {
                DLog("Image Path : \(DefaultDownloadResponse.destinationURL?.absoluteString ?? "image error")")
                responseData(nil, true)
            }
        })
        
    }

    
    //MARK: - MULTIPART REQUEST
    //func uploadImages(endpointurl:String, parameters:NSDictionary, filePath:URL, fileName:String ,responseData:@escaping ( _ error: NSError?, _ message: String?, _ responseDict: Any?,_ rStaus:Bool) -> Void)  {
        
    func uploadImages(endpointurl:String, parameters:NSDictionary, image : UIImage?, fileKey:String ,responseData:@escaping (_ data:Dictionary<String, AnyObject>?,_ error:NSError?,_ message:String, _ rStaus:Bool) -> Void)  {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if image != nil {
                multipartFormData.append(UIImageJPEGRepresentation(image!, 1)!, withName: fileKey, fileName: "abc.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameters {
                var valueStr:String = ""
                if let intVlaue:Int   = value as? Int{
                    valueStr = String(format:"%d",intVlaue)
                }else{
                    valueStr = value as! String
                }
                multipartFormData.append(valueStr.data(using: String.Encoding.utf8)!, withName: key as! String)
            }
        }, to:endpointurl)
        { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                
                upload.responseJSON { response in
                    
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print(response.request!)  // original URL request
                        
                        guard let responseJSON:NSDictionary = response.result.value as? NSDictionary else {
                            print("Invalid tag information received from the service")
                            responseData(nil, nil, "Failed to parse data", false)
                            return
                        }
                        
                        self.Message = responseJSON["message"] as! String
                        var st:Bool = false
                        switch (responseJSON["status"] as! NSInteger) {
                            
                        case RESPONSE_STATUS.VALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = true
                            break
                            
                        case RESPONSE_STATUS.INVALID.rawValue :
                            self.responseObjectDic = (responseJSON as AnyObject?) as! Dictionary<String, AnyObject>
                            st = false
                            break
                            
                        default :
                            break
                            
                        }
                        
                        responseData(self.responseObjectDic, nil, self.Message, st)
                    }
                }
                
            case .failure(let error):
                responseData(nil, error as NSError?, "Failed", false)
                break
            }
        }

    }
    
}
