//
//  Double.swift
//  nottl
//
//  Created by Craig Mathieson on 2019-01-09.
//  Copyright © 2019 Craig Mathieson. All rights reserved.
//

import Foundation

extension Double {
    func truncate(places: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = places
        formatter.maximumFractionDigits = places
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber)
    }
}
