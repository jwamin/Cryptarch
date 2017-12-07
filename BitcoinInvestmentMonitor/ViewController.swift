//
//  ViewController.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableViewParent:TableViewController?
    
    @IBOutlet weak var btcAmountField: UITextField!
    @IBOutlet weak var rateAtPurchaseField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Add BTC Buy"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(false)
//    }
    
    @IBAction func endEditing(_ sender:Any){
        view.endEditing(false)
    }
    
    @IBAction func add(_ sender: Any) {
        
        var buyInfo:Dictionary<String,String> = [:]
        buyInfo["date"] = DateFormatter().string(from: datePicker.date)
        buyInfo["btcAmount"] = btcAmountField.text
        buyInfo["btcRate"] = rateAtPurchaseField.text
        
        tableViewParent?.btcManager.commitToCore(buyInfo:buyInfo)
        navigationController?.popViewController(animated: true)
    }
    
}

