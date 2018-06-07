//
//  JOSSYRingView.swift
//  CellHelpers
//
//  Created by Joss Manger on 6/6/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import QuartzCore
import UIKit

public class NewCell : UITableViewCell{
    @IBOutlet public weak var priceAtBuy: UILabel!
    @IBOutlet public weak var currentPrice: UILabel!
    @IBOutlet public weak var pieView: PieView!
    var ticker:TickerView!
    public func initialiseTickerView(isRising:Bool=true){
        ticker = TickerView(parent: self, isRising: isRising)
        ticker.backgroundColor = UIColor.clear
        self.addSubview(ticker)
    }
    
    @IBOutlet public weak var toplabel: UILabel!
    @IBOutlet public weak var bottomlabel: UILabel!
}


@IBDesignable
public class PieView : UIView{
    
    @IBInspectable public var percentage:Double = 0.5 {
        didSet{
            updateLayerProperties()
            
        }
    }
    @IBInspectable public var lineWidth:Double = 10.0 {
        didSet{
            updateLayerProperties()
            
        }
    }
    
    func animate(percentFloat:CGFloat){
        if(ringLayer != nil){
            
            var normalFloat:CGFloat = {
                switch percentFloat {
                case let p where p > 1.0:
                    return 1.0
                case let p where p < -1.0:
                    return -1.0
                default:
                    return percentFloat
                }
            }()
            
            if ((normalFloat > -0.1) || (normalFloat < 0.1)){
                print("normalFloat \(normalFloat)")
                let animation = CASpringAnimation(keyPath: "strokeEnd")
                animation.damping = 10
                animation.initialVelocity = 0.2
                animation.fromValue = 0.0
                animation.toValue = normalFloat
                animation.duration = 3.0
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                ringLayer.add(animation, forKey: nil)
            } else {
                ringLayer.strokeEnd = normalFloat
            }

            
        }
    }
    
    var backgroundRingLayer: CAShapeLayer!
    var ringLayer:CAShapeLayer!
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layoutSubviews()
    }
    
    func updateLayerProperties(){
        if(ringLayer != nil){
            
            var percentFloat = CGFloat(percentage)
            
            
            var strokeColor = UIColor.lightGray
            
            switch percentFloat {
            case let a where a <= 0.0:
                strokeColor = UIColor.red
                let bez = UIBezierPath(ovalIn: getInsetRect()).reversing()
                ringLayer.path = bez.cgPath
                percentFloat = 0 - percentFloat
            case let a where a > 0.0:
                strokeColor = UIColor.green
            default:
                print("fall through")
            }
            
            ringLayer.strokeColor = strokeColor.cgColor
            animate(percentFloat:percentFloat)
        }
        
    }
    

    
    func getInsetRect()->CGRect{
        var rect = bounds
        rect = rect.insetBy(dx: CGFloat(lineWidth) / 2.0, dy: CGFloat(lineWidth)/2.0)
        return rect
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !(backgroundRingLayer != nil){
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            
            let rect = getInsetRect()
            let path = UIBezierPath(ovalIn: rect)
            
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.lineWidth = CGFloat(lineWidth)
            backgroundRingLayer.strokeColor = UIColor(white: 0.5, alpha: 0.3).cgColor
            
            backgroundRingLayer.path = path.cgPath
        }
        backgroundRingLayer.frame = layer.bounds
        
        if !(ringLayer != nil){
            ringLayer = CAShapeLayer()
            var rect = bounds
            rect = rect.insetBy(dx: CGFloat(lineWidth) / 2.0, dy: CGFloat(lineWidth)/2.0)
            let path = UIBezierPath(ovalIn: rect)
            
            
            ringLayer.fillColor = nil
            ringLayer.lineWidth = CGFloat(lineWidth)
            ringLayer.path = path.cgPath
            ringLayer.lineCap = "round"
            //transform for pie
            ringLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            //print(ringLayer.anchorPoint)
            ringLayer.transform = CATransform3DRotate(ringLayer.transform, -.pi/2, 0, 0, 1)
            
            
            
            layer.addSublayer(ringLayer)
        }
        
        ringLayer.frame = layer.bounds
        updateLayerProperties()
    }
}


class TickerView : UIView {
    
    var rising:Bool = true
    
    init(parent:UIView,isRising:Bool=true) {
        
        var rect = CGRect()
        
        let dimension:CGFloat = 10.0
        let constantMaybe:CGFloat = 1
        let xcoord = (parent.frame.width)-(dimension * constantMaybe)
        let ycoord = (parent.frame.height)-(dimension * constantMaybe)
        let offset:CGFloat = 3.0
        //let backup = CGRect(x: 0.0, y: 0.0, width: dimension, height: dimension)
        if (isRising){
            rect = CGRect(x: xcoord-offset, y: 0.0+offset, width: dimension, height: dimension)
        } else {
            rect = CGRect(x: xcoord-offset, y: ycoord-offset, width: dimension, height: dimension)
        }
        //rect = backup
        
        super.init(frame: rect)
        rising = isRising
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        let path = CGPath(rect: rect, transform: nil)
        context?.addPath(path)
        context?.fillPath()
        
        context?.beginPath()
        
        //Going UP
        if(rising){
            context?.setFillColor(UIColor.green.cgColor)
            context?.move(to: CGPoint(x: 0, y: 0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: 0.0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            context?.addLine(to: CGPoint(x: 0, y: 0))
        } else { //Going down
            context?.setFillColor(UIColor.red.cgColor)
            context?.move(to: CGPoint(x: self.frame.width, y: 0.0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            context?.addLine(to: CGPoint(x: 0.0, y: self.frame.height))
        }
        
        context?.closePath()
        context?.fillPath()
        
        
    }
    
}
