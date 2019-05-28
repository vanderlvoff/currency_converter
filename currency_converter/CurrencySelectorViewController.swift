//
//  CurrencyPickerViewController.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/24.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import PMAlertController

class CurrencySelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var currencyNames: [String] = []
    var filteredArray: [String] = []
    var descriptions: [String:String] = [:]
    var rates: [String] = []
    var currencyModelObj: CurrencyModel!
    var segDirection: String = ""
    var rowNumber: Int!
    var fromName = ""
    var toName = ""
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currenciesCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "selectorCell", for: indexPath) as! CurrencySelectorCell
        
        // セルに表示する値を設定する
        cell.currencyName.text = filteredArray[indexPath.row]
        
        if rates.count > 0 {
            cell.currencyRate.text = rates[indexPath.row]
        }
        cell.currencyLongName.text = descriptions[filteredArray[indexPath.row]]
        
        if filteredArray.indices.contains(indexPath.row) && filteredArray[indexPath.row] == fromName {
            cell.backgroundColor = UIColor(rgb: 0x0096FF)
        } else if filteredArray.indices.contains(indexPath.row) && filteredArray[indexPath.row] == toName {
            cell.backgroundColor = UIColor(rgb: 0x4F8F00)
        } else {
            cell.backgroundColor = UIColor(rgb: 0xDDDDDD)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredArray = currencyNames
        currenciesCollection.delegate = self
        currenciesCollection.dataSource = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(searchText: searchText)
    }
    
    func updateSearchResults(searchText: String) {
        if (searchText.count > 0) {
            self.filteredArray = currencyNames.filter { $0.contains(searchText) }
        } else {
            filteredArray = currencyNames
        }
        self.currenciesCollection.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Show alert on bad network
        if !Connectivity.isConnectedToInternet() {
            let alertVC = PMAlertController(title: "Check your internet connection!", description: "", image: UIImage(named: "network.png"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: NSLocalizedString("CLOSE", comment:"close"), style: .cancel, action: { () -> Void in
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    //set certain currency code to "from" or to "to" slots
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setCurrency" {
            currencyModelObj = CurrencyModel()
            currencyModelObj.initializeStorage();
            currencyModelObj._name = segDirection
            currencyModelObj._jsonData = filteredArray[rowNumber]
            currencyModelObj.saveRow()
        }
    }
    
    //Set currency on calculator window
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        rowNumber = indexPath.row
        performSegue(withIdentifier: "setCurrency", sender: nil)
    }
    
    // This one is for header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "selectorHeader", for: indexPath) as? SectionHeader else {
            fatalError("Could not find proper header")
        }
        
        if kind == UICollectionView.elementKindSectionHeader {
            header.sectionLabel.text = "Select currency"
            return header
        }
        return UICollectionReusableView()
    }
}
