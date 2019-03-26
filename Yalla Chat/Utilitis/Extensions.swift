//
//  Extension.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import MessageKit

extension UITextField{
    
    var textOrNil: String?{
        return isEmpty() ? nil : text
    }
    
    func isEmpty() -> Bool{
        return self.text == nil || self.text!.isEmpty
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

extension UIImageView{
    func setImage(with url: String) {
        guard !url.isEmpty, let _ = URL(string: url) else { return }
        cacheImage(from: url) { (image, key) in
            if url == key {
                self.image = image
            }
        }
    }
}

extension UIImage: MediaItem {
    public var url: URL? { return nil }
    public var image: UIImage? { return self }
    public var placeholderImage: UIImage { return self }
    public var size: CGSize { return  CGSize.zero }
}

extension UIViewController{
    func makeRootAndPresent() {
        guard let window = UIApplication.shared.delegate!.window! else { return }
        guard let rootViewController = window.rootViewController else { return }
        self.view.frame = rootViewController.view.frame
        self.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = self
        }, completion: { _ in })
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
    
    func messageKitStyle(){
        navigationBar.tintColor = .primary
        navigationBar.prefersLargeTitles = true
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.primary]
        navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes
        toolbar.tintColor = .primary
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
