//
//  SearchBarExtensions.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/12/2021.
//

import Foundation
import UIKit

// Source: https://betterprogramming.pub/how-to-change-the-placeholder-color-in-a-uisearchbar-1f47e5266e10
extension UISearchBar {
    public var textField: UITextField? {
        if #available(iOS 13, *) {
            return searchTextField
        }
        
        let subviews = subviews.flatMap { $0.subviews }
        
        guard let textField = (subviews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        
        return textField
    }
    
    // ATTENTION: cela ne fonctionne que dans viewDidAppear() dans un ViewController.
    func changePlaceholderColor(_ color: UIColor) {
        guard let UISearchBarTextFieldLabel: AnyClass = NSClassFromString("UISearchBarTextFieldLabel"), let field = textField else {
            return
        }
        
        for subview in field.subviews where subview.isKind(of: UISearchBarTextFieldLabel) {
            (subview as! UILabel).textColor = color
        }
    }
}
