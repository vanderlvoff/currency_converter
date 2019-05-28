//
//  CurrencyPickerViewController.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/24.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import PMAlertController

class CurrencySelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var currencyNames: [String] = []
    var descriptions: [String:String] = [:]
    var rates: [String] = []
    var currencyModelObj: CurrencyModel!
    var segDirection: String = ""
    var rowNumber: Int!
    var fromName = ""
    var toName = ""
    
    @IBOutlet weak var currenciesTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyNames.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currenciesTable.delegate = self
        currenciesTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet() {
            let alertVC = PMAlertController(title: "Check your internet connection!", description: "", image: UIImage(named: "network.png"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: NSLocalizedString("CLOSE", comment:"close"), style: .cancel, action: { () -> Void in
            }))
            
            self.present(alertVC, animated: true, completion: nil)
            //            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setCurrency" {

                currencyModelObj = CurrencyModel()
                currencyModelObj.initializeStorage();
                
                currencyModelObj._name = segDirection
                currencyModelObj._jsonData = currencyNames[rowNumber]
                currencyModelObj.saveRow()

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = currenciesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        var textToShow = currencyNames[indexPath.row] + " / " + descriptions[currencyNames[indexPath.row]]!
        if rates.count > 0 {
            textToShow += " / " + rates[indexPath.row]
        }
        cell.textLabel?.text = textToShow
        
        if currencyNames.indices.contains(indexPath.row) && currencyNames[indexPath.row] == fromName {
            cell.backgroundColor = UIColor(rgb: 0x0096FF)
        } else if currencyNames.indices.contains(indexPath.row) && currencyNames[indexPath.row] == toName {
            cell.backgroundColor = UIColor(rgb: 0x4F8F00)
        } else {
            cell.backgroundColor = UIColor(rgb: 0xDDDDDD)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowNumber = indexPath.row
        performSegue(withIdentifier: "setCurrency", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        let sectionName = NSLocalizedString("Select currency.", comment: "Select currency")
        return sectionName
    }
}

