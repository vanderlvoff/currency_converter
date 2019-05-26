//
//  CurrencyListModel.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/24.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import SQLite

class CurrencyModel: BaseModel {
    
    //Fields settings
    var id = Expression <Int>("id")
    var name = Expression<String>("param_name")
    var jsonData = Expression<String>("json_data")
    var created = Expression<Int64>("created")
    var updated = Expression<Int64>("updated")
    
    //Model attributes
    var _name: String = ""
    var _jsonData: String = ""
    
    let tableName: String = "currency"
    var currencyTable: Table!
    
    override func initializeStorage() {
        super.initializeStorage()
        self.currencyTable = Table(self.tableName)
        createCurrencyTable()
    }
    
    func createCurrencyTable() {
        do {
            try db?.run(currencyTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(jsonData)
                t.column(updated)
                t.column(created)
            })
        } catch {
            //do nothing
            print("CurrencyTable creation failed: \(error)")
        }
    }
  
    func saveRow() {
        let checkRow = getDataByName(paramName: self._name)
        if checkRow.count == 0 {
            insertRow()
        } else {
            updateRow(paramName: self._name)
        }
    }
    
    func getDataByName(paramName: String)->[Row] {
        var returningRows: [Row] = []
        do {
            let row = Array(try db.prepare(currencyTable.filter(name == paramName)))
            returningRows = row
        } catch {
            //do nothing
            print("Trouble: \(error)")
        }
        return returningRows
    }
    
    func insertRow() {
        let common_time = Int64(NSDate().timeIntervalSince1970)
        let records = Table(self.tableName)
        
        let insert = records.insert(name <- _name, jsonData <- _jsonData, updated <- common_time, created <- common_time)
        do {
            try db?.run(insert)
        } catch {
            print("Failed to save to sqlite: \(error.localizedDescription)")
        }
    }
    
    func updateRow(paramName: String) {
        initializeStorage();
        let _updated = Int64(NSDate().timeIntervalSince1970)
        do {
            let record = currencyTable.filter(name == paramName)
            try db.run(record.update(jsonData <- _jsonData, updated <- _updated))
        } catch {
            //do nothing
            print("Trouble: \(error.localizedDescription)")
        }
    }
}
