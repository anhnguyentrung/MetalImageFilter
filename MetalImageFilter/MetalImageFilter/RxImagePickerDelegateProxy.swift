//
//  RxImagePickerDelegateProxy.swift
//  MetalImageFilter
//
//  Created by CodeLovers2 on 4/9/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class RxImagePickerDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UIImagePickerControllerDelegate
    , UINavigationControllerDelegate {
    /// Sets designated delegate property for object.
    ///
    /// Objects can have multiple delegate properties.
    ///
    /// Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    ///
    /// - parameter toObject: Object that has delegate property.
    /// - parameter delegate: Delegate value.
    public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        imagePickerController.delegate = castOptionalOrFatalError(delegate)
    }

    /// Returns designated delegate property for object.
    ///
    /// Objects can have multiple delegate properties.
    ///
    /// Each delegate property needs to have it's own type implementing `DelegateProxyType`.
    ///
    /// - parameter object: Object that has delegate property.
    /// - returns: Value of delegate property.
    public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        return imagePickerController.delegate
    }
}

private func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

private func castOptionalOrFatalError<T>(_ value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

private func rxFatalError(_ lastMessage: String) -> Never {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}
