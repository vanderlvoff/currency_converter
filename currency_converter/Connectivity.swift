//
//  Connectivity.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/27.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    static let BASE_URL = "http://apilayer.net/api/"
    static let apiKey = "HERE_SHOULD_BE_YOUR_API_TOKEN"
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
