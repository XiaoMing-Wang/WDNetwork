//
//  WDNetwordExtension.swift
//  Multi-Project-Swift
//
//  Created by imMac on 2021/1/22.
//

import Foundation
import UIKit

extension UIViewController {

    class func wdnet_currentController(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let presented = controller?.presentedViewController {
            return wdnet_currentController(presented)
        }

        if let nav = controller as? UINavigationController {
            return wdnet_currentController(nav.topViewController)
        }
        if let tab = controller as? UITabBarController {
            return wdnet_currentController(tab.selectedViewController)
        }
        return controller
    }
        
}

fileprivate extension String {
    
    /**< 转换unicode字符串 */
    var unicodeString: String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: .utf8)
        var returnStr: String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            print(error)
            return self
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }

}

extension Dictionary {

    func parametersLog_N() -> String {
        if (self.count == 0) { return "[ : ]" }
        var string: String = ""
        for (key, value) in self {
            let keyString: String = (key is String) ? key as! String: ""
            let valueString: Any? = value
            string = string.appendingFormat("\t%@", keyString)
            string.append(" : ")
            if valueString != nil {
                var sssss = "\(valueString!)\n"
                if sssss.unicodeString != sssss, sssss.unicodeString.count > 0 {
                    sssss = sssss.unicodeString
                }
                string.append(sssss)
            }
        }
        string.append("\n")
        return string
    }

}
