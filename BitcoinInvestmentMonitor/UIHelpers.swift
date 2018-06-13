//
//  UIHelpers.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 6/13/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import UIKit

func darkModeView(view:UIView){
    view.backgroundColor = UIColor.black
    for thisView in view.subviews{
        //print(thisView)
        if thisView is UILabel{
            (thisView as! UILabel).textColor = UIColor.white
        }
        for sub in thisView.subviews{
            darkModeView(view: sub)
        }
    }
}
