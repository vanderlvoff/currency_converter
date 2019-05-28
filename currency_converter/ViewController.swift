//
//  ViewController.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/23.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PMAlertController

class ViewController: UIViewController {

    var json: JSON!
    var currencyNames: [String] = []
    var allCurrencyNames: [String] = []
    var currencyDescriptions: [String: String] = [:]
    var currencyRates: [String] = []
    var selectorMode = "to"
    var fromName = ""
    var toName = ""
    let currencyModelObj: CurrencyModel = CurrencyModel()
    var fromRates: [String: Float] = [:]
    var rateToCalculate: Float = 0.0
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var fromSelector: UIButton!
    @IBOutlet weak var toSelector: UIButton!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var currentRate: UILabel!
    @IBOutlet weak var toCurrencyLabel: UILabel!
    
    @IBOutlet weak var currencyCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currencyCollection.delegate = self as UICollectionViewDelegate
        self.currencyCollection.dataSource = self as UICollectionViewDataSource
        
        toSelector.roundedCorners()
        fromSelector.roundedCorners()
        
        currencyModelObj.initializeStorage()
        handleFromToButtons()
        handleInputSume()
        handleOutputSume()
        
        //If source currency is not selected we show just currency list
        handleCurrencyList()
        if fromName != "" {
            getRatesUsingFrom()
        }
        
        self.addDoneButtonOnKeyboard()
        outputLabel.layer.cornerRadius = 5
        outputLabel.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: Selector(("doneButtonAction")))
        done.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)

        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        self.inputTextField.inputAccessoryView = doneToolbar
        self.inputTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.inputTextField.resignFirstResponder()
        calculateSume()
    }
    
    func handleFromToButtons() {
        let fromNameRow = currencyModelObj.getDataByName(paramName: "from")
        let toNameRow = currencyModelObj.getDataByName(paramName: "to")
        do {
            if (fromNameRow.count > 0) {
                fromName = try fromNameRow[0].get(CurrencyModel().jsonData)
            }
            if (toNameRow.count > 0) {
                toName = try toNameRow[0].get(CurrencyModel().jsonData)
            }
        } catch {
            fromName = ""
            toName = ""
        }
        
        toCurrencyLabel.text = toName
        
        fromSelector.setTitle("From: "+fromName, for: .normal)
        toSelector.setTitle("To: "+toName, for: .normal)
    }
    
    func handleCurrencyList() {
        let currencyList = currencyModelObj.getDataByName(paramName: "allCurrencyList")
        let timeNow = Int64(NSDate().timeIntervalSince1970)
        if (currencyList.count > 0) {
            do {
                let updateTime = try currencyList[0].get(CurrencyModel().updated)
                let jsonString = try currencyList[0].get(CurrencyModel().jsonData)
                let data = jsonString.data(using: String.Encoding.utf8)!
                let anotherObj = JSON(data)
                self.setNamesAndDescriptions(anotherObj: anotherObj)
                
                if updateTime < timeNow-(30*60) {
                    //need to update
                    callForCurrencyList()
                }
            } catch {
                //do nothing
            }
        } else {
            //need to write
            //Db is empty so I request data from API
            callForCurrencyList()
        }
    }
    
    func callForCurrencyList() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        let url: String = Connectivity.BASE_URL+"list?access_key="+Connectivity.apiKey+"&format=1"
        AF.request(url).responseJSON { response in
            do {
                self.json = try JSON(data: response.data!)
                self.writeListToDb(nameToWrite: "allCurrencyList")
                self.setNamesAndDescriptions(anotherObj: self.json)
            } catch {
                //inform about the error
                print("\(String(describing: error))")
            }
        }
    }

    func callForCurrencyRates(from: String) {
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        let url: String = Connectivity.BASE_URL + "live?source="+from+"&access_key="+Connectivity.apiKey+"&format=1"
        AF.request(url).responseJSON { response in
            do {
                self.json = try JSON(data: response.data ?? Data())
                self.writeListToDb(nameToWrite: from)
                self.setNamesAndRates(anotherObj: self.json)
                
            } catch {
                //inform about the error
                print("\(String(describing: error))")
            }
        }
    }
    
    /**
     * Loading rate list basing on "from" value
     */
    func getRatesUsingFrom() {
        let currencyList = currencyModelObj.getDataByName(paramName: fromName)
        let timeNow = Int64(NSDate().timeIntervalSince1970)
        if (currencyList.count > 0) {
            do {
                let updateTime = try currencyList[0].get(CurrencyModel().updated)
                let jsonString = try currencyList[0].get(CurrencyModel().jsonData)
                let data = jsonString.data(using: String.Encoding.utf8)!
                let anotherObj = JSON(data)
                
                setNamesAndRates(anotherObj: anotherObj)
                
                if updateTime < timeNow-(30*60) {
                    //need to update
                    callForCurrencyRates(from: fromName)
                } else {
                    currencyCollection.reloadData()
                    calculateSume()
                }
            } catch {
                //do nothing currencyCollection
            }
        } else {
            //need to write
            callForCurrencyRates(from: fromName)
        }
    }
    
    /**
     * Creating all currency rate list
     */
    func setNamesAndRates(anotherObj: JSON) {
        currencyNames = []
        currencyRates = []
        for (key,subJson):(String, JSON) in anotherObj["quotes"] {
            currencyNames.append(String(key.suffix(3)))
            
            var rate: Float = Float(subJson.rawString()!) as! Float
            let trueRate = rate
            rate = rate * 1000
            rate = rate.rounded(FloatingPointRoundingRule.toNearestOrEven)/1000
            currencyRates.append(String(rate))
            fromRates[key] = trueRate
        }
        currencyCollection.reloadData()
        calculateSume()
    }
    
    /**
     * Creating all currency list
     */
    func setNamesAndDescriptions(anotherObj: JSON) {
        allCurrencyNames = []
        currencyDescriptions = [:]
        
        for (key,subJson):(String, JSON) in anotherObj["currencies"] {
            allCurrencyNames.append(key)
            currencyDescriptions[key] = subJson.rawString()!
        }
        currencyCollection.reloadData()
    }
    
    /**
     * Currency converter.
     */
    func calculateSume() {
        let rateKey = fromName+toName

        rateToCalculate = fromRates[rateKey] ?? 0.0
        currentRate.text = String(rateToCalculate)
        
        if rateToCalculate > 0 {
            let textedValue = (inputTextField.text == "" ? "0.0" : inputTextField.text)!
            let numberFormatter = NumberFormatter()
            let number = numberFormatter.number(from: textedValue)
            let numberFloatValue = number?.floatValue
            
            var sume: Double = Double(numberFloatValue!*rateToCalculate)*100
            sume = sume.rounded(FloatingPointRoundingRule.towardZero)/100
            outputLabel.text = String(sume)
            
            currencyModelObj._name = "inputSume"
            currencyModelObj._jsonData = textedValue
            currencyModelObj.saveRow()
            
            currencyModelObj._name = "outputSume"
            currencyModelObj._jsonData = String(sume)
            currencyModelObj.saveRow()
        }
    }
    
    /**
     * Select source currency
     */
    @IBAction func selectFrom(_ sender: Any) {
        selectorMode = "from"
        if self.allCurrencyNames.count > 0 {
            performSegue(withIdentifier: "fromToSeg", sender: sender)
        }
    }
    
    /**
    * Select destination currency
    */
    @IBAction func selectTo(_ sender: Any) {
        selectorMode = "to"
        if self.currencyNames.count > 0 {
            performSegue(withIdentifier: "fromToSeg", sender: sender)
        } else {
            let alertVC = PMAlertController(title: "First select source currency pressing \"From:\" button", description: "", image: UIImage(named: ""), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: NSLocalizedString("CLOSE", comment:"close"), style: .cancel, action: { () -> Void in
            }))
            
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    /**
     * Writing currency list to DB
     */
    func writeListToDb(nameToWrite: String) {
        currencyModelObj._name = nameToWrite
        
        if let rawString = self.json.rawString() {
            //Do something you want
            currencyModelObj._jsonData = rawString
        } else {
            currencyModelObj._jsonData = ""
        }
        currencyModelObj.saveRow()
    }
    
    /**
    * Passing lists to currency select view
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromToSeg" {
            if let viewController = segue.destination as? CurrencySelectorViewController {
                if selectorMode == "from" {
                    viewController.currencyNames = self.allCurrencyNames
                    viewController.descriptions = self.currencyDescriptions
                    
                } else {
                    viewController.currencyNames = self.currencyNames
                    viewController.rates = self.currencyRates
                    viewController.descriptions = self.currencyDescriptions
                }
                viewController.fromName = fromName
                viewController.toName = toName
                viewController.segDirection = selectorMode
            }
        }
    }
    
    /**
     * Getting from DB converted destination(sume) value once saved into Sqlite DB
     */
    func handleInputSume() {
        let inputSume = currencyModelObj.getDataByName(paramName: "inputSume")
        var text = ""
        if inputSume.count > 0 {
            do {
                try text = inputSume[0].get(CurrencyModel().jsonData)
                inputTextField.text = text
            } catch {
                //do nothing
            }
        }
    }
    
    /**
     * Getting from DB converted output value once saved into Sqlite DB
     */
    func handleOutputSume() {
        let outputSume = currencyModelObj.getDataByName(paramName: "outputSume")
        var text = ""
        if outputSume.count > 0 {
            do {
                try text = outputSume[0].get(CurrencyModel().jsonData)
                outputLabel.text = text
            } catch {
                //do nothing
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // スタンプが押された時の処理を書く
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CurrencyCell
        if (currencyNames.count > 0) {
            cell.currencyName.text = currencyNames[indexPath.row]
            cell.currencyRate.text = currencyRates[indexPath.row]
            cell.currencyLongName.text = currencyDescriptions[currencyNames[indexPath.row]]
        } else {
            cell.currencyName.text = allCurrencyNames[indexPath.row]
            cell.currencyLongName.text = currencyDescriptions[allCurrencyNames[indexPath.row]]
        }
        
        if currencyNames.indices.contains(indexPath.row) && currencyNames[indexPath.row] == fromName {
            print("\(currencyNames[indexPath.row]) == \(fromName)")
            cell.backgroundColor = UIColor(rgb: 0x0096FF)
        } else if currencyNames.indices.contains(indexPath.row) && currencyNames[indexPath.row] == toName {
            cell.backgroundColor = UIColor(rgb: 0x4F8F00)
        } else {
            cell.backgroundColor = .lightGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.currencyNames.count > 0 {
            return self.currencyNames.count
        }
        return self.allCurrencyNames.count
    }
}

extension UIButton {
    func roundedCorners() {
        self.layer.cornerRadius = 5
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
