//
//  WDNetworkResponse.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//

import Foundation

class WDNetworkResponse: NSObject {

    /**< 是否成功  */
    public var successful: Bool = false

    /**< 错误码  */
    public var errorCode: Int = -1

    public var errorMessage: String? = nil
    public var error: Error? = nil

    /**< 步骤控制 如果有的话  */
    public var stepTap: String? = nil

    /**< 处理前的数据 */
    var json: Dictionary<String, Any>? = nil
    
    /**< 处理后的数据 */
    var data: [String: Any]? = nil
    var dataString: String? = nil
    var dataObj: Any? = nil

    convenience init(errorCode: Int, error: Error?) {
        self.init()
        self.errorCode = errorCode
        self.error = error
        self.successful = (errorCode == WDNetworkConf.successCode)
    }

    convenience init(json: Dictionary<String, Any>) {
        self.init()
        self.json = json
        self.parseJson()
    }

    /**< 解析json */
    fileprivate func parseJson() {
        WDNetworkResultLoader.parseJson(response: self)
    }

}
