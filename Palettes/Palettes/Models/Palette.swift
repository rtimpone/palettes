//
//  Palette.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

struct Palette {
    
    let name: String

    let primaryColorString: String
    let secondaryColorString: String
    let tertiaryColorString: String
    let quaternaryColorString: String
    
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let tertiaryColor: UIColor
    let quaternaryColor: UIColor
    
    init(name: String, primary: String, secondary: String, tertiary: String, quaternary: String) {
        
        self.name = name

        self.primaryColorString = primary
        self.secondaryColorString = secondary
        self.tertiaryColorString = tertiary
        self.quaternaryColorString = quaternary
        
        primaryColor = UIColor(hex: primary)
        secondaryColor = UIColor(hex: secondary)
        tertiaryColor = UIColor(hex: tertiary)
        quaternaryColor = UIColor(hex: quaternary)
    }
    
    // https://colorhunt.co/palette/118869
    static let mediumGreen = Palette(name: "118869", primary: "#5ba19b", secondary: "#fceaea", tertiary: "#f5d9d9", quaternary: "#fbead1")
    
    // https://colorhunt.co/palette/111393
    static let boldGreen = Palette(name: "111393", primary: "e7f5f2", secondary: "f9c7cf", tertiary: "12776f", quaternary: "0f4137")
    
    // https://colorhunt.co/palette/98666
    static let sand = Palette(name: "98666", primary: "f5e1da", secondary: "f1f1f1", tertiary: "40a798", quaternary: "476269")
}
