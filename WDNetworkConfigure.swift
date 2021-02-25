//
//  WDNetworkMessenge.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

typealias WDNetworkResClosure = (_ response: WDNetworkResponse) -> ()
class WDNetworkConf: NSObject {
    
    /**< 请求成功的状态码 */
    static let successCode: Int = 0

    static let networkError = "无法连接网络，请检查网络配置"
    static let parseFailure = "返回数据错误，无法解析"
    static let networkConnected = "WDNoticeCof.networkConnected"
    static var networkAvailable: Bool = true

    /**< 请求过滤 */
    static var requestObjects: [String: requestObject] = [:]

    /**< 显示菊花类型  */
    enum LoadType {
        case display
        case none
        case mandatory
        case prohibit
    }

    struct requestObject {
        var path: String? = nil
        var success: [WDNetworkResClosure?] = []
        var fail: [WDNetworkResClosure?] = []
        var requestTimeStamp: UInt64? = nil
    }

    /**< manager  */
    public static let defSession: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        var header: HTTPHeaders = HTTPHeaders([:])
        header.add(.defaultAcceptEncoding)
        header.add(.defaultAcceptLanguage)
        header.add(.defaultUserAgent)
        configuration.headers = header
        configuration.timeoutIntervalForRequest = 25
        let manager = Alamofire.Session(configuration: configuration, startRequestsImmediately: true)
        return manager
    }()

    /**< 超时快的manager */
    public static let shortSession: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        var header: HTTPHeaders = HTTPHeaders([:])
        header.add(.defaultAcceptEncoding)
        header.add(.defaultAcceptLanguage)
        header.add(.defaultUserAgent)
        configuration.headers = header
        configuration.timeoutIntervalForRequest = 10
        let manager = Alamofire.Session(configuration: configuration, startRequestsImmediately: true)
        return manager
    }()
    
}
