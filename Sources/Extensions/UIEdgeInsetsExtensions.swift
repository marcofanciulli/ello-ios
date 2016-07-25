////
///  UIEdgeInsetsExtensions.swift
//

import CoreGraphics
import UIKit
import Foundation

public extension UIEdgeInsets {
    init(top: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }

    init(left: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: 0)
    }

    init(bottom: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }

    init(right: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: right)
    }

    init(sides: CGFloat) {
        self.init(top: 0, left: sides, bottom: 0, right: sides)
    }

    init(tops: CGFloat, sides: CGFloat) {
        self.init(top: tops, left: sides, bottom: tops, right: sides)
    }

    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
}
