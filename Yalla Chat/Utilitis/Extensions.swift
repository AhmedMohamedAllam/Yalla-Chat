//
//  Extension.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

extension UITextField{
    
    var textOrNil: String?{
        return isEmpty() ? nil : text
    }
    
    func isEmpty() -> Bool{
        return self.text == "" || self.text == nil
    }
}
extension UINavigationController{
    func makeTransparent() {
        navigationBar.isHidden = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear
    }
}

extension UIView{
    
    func createGradientLayerWith(_ firstColor: UIColor, _ secondColor: UIColor) {
        var gradientLayer = CAGradientLayer()
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        gradientLayer.frame = bounds
    }
    
    @IBInspectable
    var circlePaddingsView: Bool {
        get {
            return self.circlePaddingsView
        }set{
            layer.cornerRadius = self.frame.height / 2
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1.0)
            layer.shadowOpacity = 0.4
            layer.shadowRadius = shadowRadius
            clipsToBounds = false
        }
    }
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    @IBInspectable var viewCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

class GradientView: UIView{
    //Weekly sample data
    var graphPoints:[Int] = [4, 2, 6, 4, 5, 4, 1]
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor(red: 172.0, green: 214.0, blue: 255, alpha: 1.0)
    @IBInspectable var endColor: UIColor = UIColor(red: 113.0, green: 136.0, blue: 174.0, alpha: 1.0)
    
    @IBInspectable var isDiagonal: Bool = false
    //@IBInspectable var endColor: UIColor = UIColor.blue
    @IBInspectable var isVertical: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = rect.width
        let height = rect.height
        
        //set up background clipping area
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 0.0, height: 0.0))
        path.addClip()
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [1.0, 0.0]
        
        //5 - create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        //6 - draw the gradient
        var startPoint = isDiagonal ? CGPoint.zero : CGPoint(x:0, y:self.bounds.height)
        var endPoint = CGPoint(x:self.bounds.width, y:self.bounds.height)
        
        if isVertical{
            startPoint = CGPoint(x:self.bounds.width / 2, y:0)
            endPoint = CGPoint(x:self.bounds.width / 2, y: self.bounds.height)
        }
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: .drawsBeforeStartLocation)
        
        //calculate the x point
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.last
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        // draw the line graph
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        //set up the points line
        let graphPath = UIBezierPath()
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(0),
                                   y:columnYPoint(graphPoints[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                                    y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        context!.saveGState()
    }
}
