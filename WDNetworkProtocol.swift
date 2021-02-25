//
//  WDProviderProtocol.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//

import UIKit
import Alamofire
import Foundation

/** 默认协议(自定义的请求 遵循这个协议) */
protocol WDBaseAPIProtocol {
    
    /**< 路径 */
    var path: String { get }
    
    /**< 请求方式 */
    var method: HTTPMethod { get }
    
    /**< 参数 */
    var parameters: [String: Any] { get }
    
    /**< 是否加密 */
    var isEncryption: Bool { get }
    
    /**< baseURL */
    var baseURL: String { get }
    
    /**< header */
    var headers: [String: String] { get }
    
    /**< 请求过滤 true表示相同请求会合成一个 */
    var isRequestFilter: Bool { get }
}

extension WDBaseAPIProtocol {

    //MARK: 需要重写这3个参数
    /** 请求路径 */
    var path: String {
        return ""
    }
    
    /** 请求参数 外部需要使用 */
    var parameters: Dictionary<String, Any> {
        return [:]
    }

    /** 请求方式 */
    var method: HTTPMethod {
        return .post
    }

    /** baseURL */
    var baseURL: String {
        return ""
    }

    /** headers */
    var headers: [String: String] {
        return [:]
    }

    /** 是否加密 */
    var isEncryption: Bool {
        return false
    }
    
    /** 是否加密 */
    var isRequestFilter: Bool {
        return true
    }
    
    /// request
    /// - Parameters:
    ///   - loadType: 菊花类型
    ///   - controller: 显示菊花的控制器
    ///   - success: success
    ///   - fail: success
    func requestType(
        _ controller: UIViewController? = UIViewController.wdnet_currentController(),
        loadType: WDNetworkConf.LoadType = .mandatory,
        success: WDNetworkResClosure? = nil,
        fail: WDNetworkResClosure? = nil) {

        var networkHandle: WDNetworkLoader = WDNetworkLoader.def
        switch loadType {
        case .display: networkHandle = WDNetworkLoader.def
        case .none: networkHandle = WDNetworkLoader.none
        case .mandatory: networkHandle = WDNetworkLoader.mandatory
        case .prohibit: networkHandle = WDNetworkLoader.prohibit
        }
        networkHandle.requestType(self, controller: controller, success: success, fail: fail)
    }

}
