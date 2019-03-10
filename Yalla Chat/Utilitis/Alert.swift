//
//  Alert.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/9/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import SwiftMessages


struct Alert {
    
    static func showMessage(message: String, theme: Theme) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        // Theme message elements with the warning style.
        view.configureTheme(theme)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: "", body: message, iconText: themeIcon(from: theme))
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    private static  func themeIcon(from theme: Theme) -> String{
        switch theme {
        case .error:
            return "⚠️"
        case .success:
            return "✅"
        case .info:
            return "ℹ️"
        case .warning:
            return "❌"
        }
    }
    
}
