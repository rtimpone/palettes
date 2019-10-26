//
//  Animator.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

struct Animator {
    
    static func animate(view: UIView, duration: TimeInterval, changes: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [], animations: {
            changes()
            view.layoutIfNeeded()
        })
    }
}
