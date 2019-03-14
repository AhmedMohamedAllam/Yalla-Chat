//
//  IndicatorLoading.swift
//  Dallaty
//
//  Created by macbook on 2/13/19.
//  Copyright © 2019 Abdallah omer. All rights reserved.
//

import UIKit

class IndicatorLoading {
    static var activityIndicator = UIActivityIndicatorView()
    
    static func showLoading(_ view: UIView) {
        view.isUserInteractionEnabled = false
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.blue
        activityIndicator.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    static func hideLoading(_ view: UIView) {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
