//
//  WDNetworkLoader.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

fileprivate var networkManager: NetworkReachabilityManager? = nil
class WDNetworkLoader: NSObject {

    static let def = WDNetworkLoader(type: .display)
    static let none = WDNetworkLoader(type: .none)
    static let mandatory = WDNetworkLoader(type: .mandatory)
    static let prohibit = WDNetworkLoader(type: .prohibit)
    fileprivate var type: WDNetworkConf.LoadType = .none

    convenience init(type: WDNetworkConf.LoadType) {
        self.init()
        self.type = type
    }
    
    //MARK: Provider请求
    ///   Provider请求
    ///   - Parameters:
    ///   - type: 请求类型自定义
    ///   - controller: 显示菊花和toast的控制器 传nil会获取导航控制器topController
    ///   - success: 成果回调(状态码 = 1)
    ///   - fail: 失败回调(所有失败)
    public func requestType<T:WDBaseAPIProtocol>(
        _ api: T,
        controller: UIViewController? = nil,
        success: WDNetworkResClosure? = nil,
        fail: WDNetworkResClosure? = nil) {

        showLoadingController(controller: controller)
        generalSettings(path: "\(api.baseURL)\(api.path)", parameter: api.parameters)
        baseRequestType(api, controller: controller, success: success, fail: fail)
    }

    /// 全路径请求
    /// - Parameters:
    ///   - fullPath: 完成的url
    ///   - succ: 成功回调
    ///   - ail: 失败回调
    public func requestFullPath(
        _ fullPath: String,
        method: HTTPMethod = .get,
        parameters: [String: Any] = [:],
        success: WDNetworkResClosure? = nil,
        fail: WDNetworkResClosure? = nil) {
        WDNetworkConf.shortSession.request(fullPath, method: method, parameters: parameters).responseJSON(queue: .main) { (response) in

            /**< 成功 不管报错与否 200状态码就算成功 */
            if case let .success(json) = response.result, let dictionary = json as? [String: Any] {
                success?(WDNetworkResponse(json: dictionary))
            }

            /**< 失败 */
            if case let .failure(error) = response.result {
                fail?(WDNetworkResponse(errorCode: 404, error: error as Error))
            }
        }
    }
    
    //MARK: base请求
    fileprivate func baseRequestType<T:WDBaseAPIProtocol>(
        _ api: T,
        controller: UIViewController?,
        success: WDNetworkResClosure?,
        fail: WDNetworkResClosure?) {
        
        /**< 无网络  */
        if WDNetworkConf.networkAvailable == false {
            let response = WDNetworkResponse(errorCode: 404, error: nil)
            WDNetworkResultLoader.handleResponse(response, controller, api.path)
            fail?(response)
            return
        }
                
        /**< 请求过滤的接口 */
        if api.isRequestFilter {
            
            /**< 有相同的接口正在请求 */
            if var requestObj = WDNetworkConf.requestObjects[api.path] {
                requestObj.success.append(success)
                requestObj.fail.append(fail)
                requestObj.requestTimeStamp = UInt64(Date().timeIntervalSince1970)
                return
            }

            /**< 无相同正在请求的接口 */
            var requestObj = WDNetworkConf.requestObject()
            requestObj.path = api.path
            requestObj.success = [success]
            requestObj.fail = [fail]
            requestObj.requestTimeStamp = UInt64(Date().timeIntervalSince1970)
            WDNetworkConf.requestObjects[api.path] = requestObj
        }
        
        let requestUrl = api.baseURL + api.path
        let method = api.method
        let parameters = WDNetworkResultLoader.commomParameter(parameter: api.parameters)
        let manager = WDNetworkConf.defSession
        manager.request(requestUrl, method: method, parameters: parameters).responseJSON(queue: .main) { [unowned self] (response) in
            self.hideLoadingController(controller: controller)

            /**< 回调 */
            func completionHandler(_ networkResponse: WDNetworkResponse, isSuccessful: Bool = false) {
                guard api.isRequestFilter else {
                    isSuccessful ? success?(networkResponse) : fail?(networkResponse)
                    return
                }
                
                if let requestObj = WDNetworkConf.requestObjects[api.path] {
                    let callbacks = isSuccessful ? requestObj.success : requestObj.fail
                    for callback in callbacks { callback?(networkResponse) }
                }
            }

            /**< 成功 只有状态码 = 1才走success回调 fail回调可以忽略不处理(有统一处理的地方) */
            if case let .success(json) = response.result, let dictionary = json as? [String : Any] {
                let networkResponse = WDNetworkResponse(json: dictionary)
                completionHandler(networkResponse, isSuccessful: networkResponse.successful)
                WDNetworkResultLoader.handleResponse(networkResponse, controller, api.path)
                #if DEBUG
                    var log = true
                    if api.path == "xxxxxx" { log = false }
                    print("完成请求: 🔥🔥🔥 \(requestUrl)🔥🔥🔥")
                    if (log) { print(dictionary.parametersLog_N()) }
                #endif
            }
            
            /**< http本身的请求错误 */
            else if case let .failure(error) = response.result {
                let response = WDNetworkResponse(errorCode: 404, error: error as Error)
                completionHandler(response)
                WDNetworkResultLoader.handleResponse(response, controller, api.path)
            }
            
            /**< 删掉请求 */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                WDNetworkConf.requestObjects[api.path] = nil
            }
        }
    }

}

extension WDNetworkLoader {
    
    /** 请求前通用的处理 */
    fileprivate func generalSettings(path: String, parameter: Dictionary<String, Any>?) {
        #if DEBUG
            print("正在请求接口🍀🍀🍀--->\(path)🍀🍀🍀")
            print(WDNetworkResultLoader.commomParameter(parameter: parameter!).parametersLog())
        #endif
    }
    
    /** 显示弹窗 */
    fileprivate func showLoadingController(controller: UIViewController?) {
        guard controller != nil else { return }
        switch type {
        case .display: WDNetworkResultLoader.showLoadingDef(controller!)
        case .none: WDNetworkResultLoader.hideLoading(controller!)
        case .mandatory: WDNetworkResultLoader.showLoadingDisable(controller!)
        case .prohibit: WDNetworkResultLoader.showLoadingForbid(controller!)
        }
    }

    /** 隐藏弹窗 */
    fileprivate func hideLoadingController(controller: UIViewController?) {
        guard controller != nil else { return }
        WDNetworkResultLoader.hideLoading(controller!)
    }

    /** 显示错误信息 */
    fileprivate func showErrorMessage(controller: UIViewController?, message: String) {
        guard controller != nil else { return }
        WDNetworkResultLoader.showMessage(controller, message)
    }
    
    /** 参数加密(自定义的在配置中调用加密) */
    class func configurationParameters(path: String, parameter: Dictionary<String, Any>) -> Dictionary<String, Any> {
        return parameter
    }
    
    /** 参数解密 */
    class func decryptionResponse(path: String, parameter: Dictionary<String, Any>) -> Dictionary<String, Any> {
        return parameter
    }
    
    /** 判断网络 */
    class func alamofiremonitorNet(complete: ((Bool) -> Void)? = nil) {
        guard networkManager == nil else {
            complete?(WDNetworkConf.networkAvailable)
            return
        }
        
        func postNotification() {
            let name = NSNotification.Name(rawValue: WDNetworkConf.networkConnected)
            let object = WDNetworkConf.networkAvailable
            NotificationCenter.default.post(name: name, object: object)
        }

        networkManager = NetworkReachabilityManager()
        networkManager?.startListening(onUpdatePerforming: { (status) in
            if status == .reachable(.ethernetOrWiFi) {

                WDNetworkConf.networkAvailable = true
                complete?(true)
                postNotification()

            } else if status == .reachable(.cellular) {

                WDNetworkConf.networkAvailable = true
                complete?(true)
                postNotification()

            } else if status == .notReachable {

                WDNetworkConf.networkAvailable = false
                complete?(false)
                postNotification()
            }
        })
    }

    
}
