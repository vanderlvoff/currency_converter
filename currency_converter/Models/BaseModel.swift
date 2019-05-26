//
//  BaseModel.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/24.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import SQLite

class BaseModel {
    
    var db: Connection!
    
    func initializeStorage() {
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
            ).first! + "/" + Bundle.main.bundleIdentifier!
        do {
            // create parent directory iff it doesn’t exist
            try FileManager.default.createDirectory(
                atPath: path, withIntermediateDirectories: true, attributes: nil
            )
            
            db = try Connection("\(path)/db.sqlite3")
        } catch {
            print("some error")
        }
    }
}
