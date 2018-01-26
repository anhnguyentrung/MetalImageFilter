//
//  String.swift
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/8/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
}
