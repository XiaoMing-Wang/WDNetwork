//
//  WDNetworkResultLoader.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//
import UIKit
import Foundation

class WDNetworkResultLoader: NSObject {
    
    //MARK: 添加公共参数
    class func commomParameter(parameter: [String: Any]) -> [String: Any] {
        return parameter
    }

    //MARK: 解析json
    class func parseJson(response: WDNetworkResponse) {

    }

    //MARK: 统一处理结果
    class func handleResponse(_ response: WDNetworkResponse, _ controller: UIViewController?, _ path: String) {

    }

}

/** 界面元素 */
extension WDNetworkResultLoader {

    /** 可以操作 */
    class func showLoadingDef(_ controller: UIViewController) {
        /**< controller.showLoading() */
    }

    /** 不可操作 */
    class func showLoadingDisable(_ controller: UIViewController) {
        /**< controller.showLoadViewDisable() */
    }

    /** 不可操作 手势也关闭 */
    class func showLoadingForbid(_ controller: UIViewController) {
        /**< controller.showLoadViewForbid() */
    }

    /** 隐藏 */
    class func hideLoading(_ controller: UIViewController) {
        /**< controller.hideLoading() */
    }

    /** 隐藏 */
    class func showMessage(_ controller: UIViewController?, _ message: String) {
        guard controller != nil else { return }
        /**< controller!.showMessage(message) */
    }

    /** 是否显示菊花 */
    class func showErrorToast(_ path: String, _ controller: UIViewController?) -> Bool {
        return true
    }
    
}
