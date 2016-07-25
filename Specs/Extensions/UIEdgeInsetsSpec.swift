////
///  UIEdgeInsetsSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UIEdgeInsetsSpec: QuickSpec {
    override func spec() {
        describe("UIEdgeInsets") {
            describe("convenience initializers") {
                it("supports UIEdgeInsets(top:)") {
                    let insets = UIEdgeInsets(top: 10)
                    expect(insets.top) == 10
                    expect(insets.left) == 0
                    expect(insets.bottom) == 0
                    expect(insets.right) == 0
                }
                it("supports UIEdgeInsets(left:)") {
                    let insets = UIEdgeInsets(left: 10)
                    expect(insets.top) == 0
                    expect(insets.left) == 10
                    expect(insets.bottom) == 0
                    expect(insets.right) == 0
                }
                it("supports UIEdgeInsets(bottom:)") {
                    let insets = UIEdgeInsets(bottom: 10)
                    expect(insets.top) == 0
                    expect(insets.left) == 0
                    expect(insets.bottom) == 10
                    expect(insets.right) == 0
                }
                it("supports UIEdgeInsets(right:)") {
                    let insets = UIEdgeInsets(right: 10)
                    expect(insets.top) == 0
                    expect(insets.left) == 0
                    expect(insets.bottom) == 0
                    expect(insets.right) == 10
                }
                it("supports UIEdgeInsets(sides:)") {
                    let insets = UIEdgeInsets(sides: 10)
                    expect(insets.top) == 0
                    expect(insets.left) == 10
                    expect(insets.bottom) == 0
                    expect(insets.right) == 10
                }
                it("supports UIEdgeInsets(tops:,sides:)") {
                    let insets = UIEdgeInsets(tops: 11, sides: 10)
                    expect(insets.top) == 11
                    expect(insets.left) == 10
                    expect(insets.bottom) == 11
                    expect(insets.right) == 10
                }
                it("supports UIEdgeInsets(all:)") {
                    let insets = UIEdgeInsets(all: 10)
                    expect(insets.top) == 10
                    expect(insets.left) == 10
                    expect(insets.bottom) == 10
                    expect(insets.right) == 10
                }
            }
        }
    }
}
