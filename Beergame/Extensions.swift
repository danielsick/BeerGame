//
//  Util.swift
//  Beergame
//
//  Created by moaiOS on 11.01.16.
//  Copyright © 2016 Alpha. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /**
     Shows a popup alert.
     - parameters:
        - title: Title of the popup.
        - message: Message of the popup.
    */
    func showAlert(title: String, message: String) {
        showAlert(title, message: message, handler: nil)
    }
    
    /**
     Shows a popup alert and performs actions defined in callback afterwards.
     - parameters:
        - title: Title of the popup.
        - message: Message of the popup.
        - handler: Callback method.
     */
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        self.presentViewController(alert, animated: true) { }
    }
    
    /**
     Shows a popup alert (gets executed on main queue).
     - parameters:
        - title: Title of the popup.
        - message: Message of the popup.
     */
    func showAlertAsync(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showAlert(title, message: message)
        }
    }
    
    /**
     Shows a popup alert and performs actions defined in callback afterwards (gets executed on main queue).
     - parameters:
        - title: Title of the popup.
        - message: Message of the popup.
        - handler: Callback method.
     */
    func showAlertAsync(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showAlert(title, message: message, handler: handler)
        }
    }
}