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
    static let BASE_URL = "https://apilayer.net/api/"
    static let apiKey = "ADD_YOUR_API_TOKEN_HERE"
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
