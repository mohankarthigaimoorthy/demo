//
//  ColorTransformer.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//

import UIKit

class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
    
    static func register() {
        let className = String(describing: ColorTransformer.self)
        let name = NSValueTransformerName(className)
        
        let transformer = ColorTransformer()
        ValueTransformer.setValueTransformer(
            transformer, forName: name)
    }
}
