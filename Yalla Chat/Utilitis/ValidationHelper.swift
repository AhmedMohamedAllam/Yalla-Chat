//
//  ValidationHelper.swift
//  Dallaty
//
//  Created by macbook on 2/9/19.
//  Copyright © 2019 Abdallah omer. All rights reserved.
//

import UIKit

class ValidationHelper {
    static func isValid(_ phone: String) -> Bool{
        let phoneRegEx = "/^(009665|9665|\\+9665|05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$/"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
    
    static func isValidCode(_ code: String) -> Bool{
       return code.count == 6
    }
    
//    static func isValid(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: email)
//    }
    
    static func isThis(_ password: String, IdenticalWith rePassowrd: String) -> Bool {
        if password == rePassowrd {
            return true
        } else {
            return false
        }
    }
}
