//
//  BrightnessAnalyzer.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import CoreGraphics
import UIKit

struct BrightnessAnalyzer {
    
    static func colorIsLight(_ color: UIColor) -> Bool {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let components = color.cgColor.components!
        let c1 = (components[0] * 299)
        let c2 = (components[1] * 299)
        let c3 = (components[2] * 114)
        let brightness = (c1 + c2 + c3) / 1000
        return brightness > 0.5
    }
}
