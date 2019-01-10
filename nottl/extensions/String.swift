//
//  string.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-22.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}
