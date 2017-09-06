//
//  MetalImageView+Rx.swift
//  CityNetwork
//
//  Created by CodeLovers2 on 4/15/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: MetalImageView {
    
    /// Bindable sink for `image` property.
    internal var image: UIBindingObserver<Base, UIImage?> {
        return image(transitionType: nil)
    }
    
    /// Bindable sink for `image` property.
    
    /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    internal func image(transitionType: String? = nil) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base) { metalImageView, image in
            if let transitionType = transitionType {
                if image != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    metalImageView.layer.add(transition, forKey: kCATransition)
                }
            }
            else {
                metalImageView.layer.removeAllAnimations()
            }
            metalImageView.image = image
        }
    }
}
