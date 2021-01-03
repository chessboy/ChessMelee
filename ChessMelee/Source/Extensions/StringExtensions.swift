//
//  StringExtensions.swift
//  ChessViz
//
//  Created by Robert Silverman on 3/22/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import Foundation

extension StringProtocol {
    func indexDistance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func indexDistance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}
extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}
extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension String {
	
	//https://stackoverflow.com/questions/42192289/is-there-a-built-in-swift-function-to-pad-strings-at-the-beginning
	func padding(leftTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		let rightPadded = self.padding(toLength:max(count,paddedLength), withPad:pad, startingAt:padStart)
		return "".padding(toLength:paddedLength, withPad:rightPadded, startingAt:count % paddedLength)
	}

	func padding(rightTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		return self.padding(toLength:paddedLength, withPad:pad, startingAt:padStart)
	}

	func padding(sidesTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		let rightPadded = self.padding(toLength:max(count,paddedLength), withPad:pad, startingAt:padStart)
		return "".padding(toLength:paddedLength, withPad:rightPadded, startingAt:(paddedLength+count)/2 % paddedLength)
	}
}

extension String {
	
	enum TruncationPosition {
		case head
		case middle
		case tail
	}

	func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
		guard self.count > limit else { return self }

		switch position {
		case .head:
			return leader + self.suffix(limit)
		case .middle:
			let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))

			let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
			
			return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
		case .tail:
			return self.prefix(limit) + leader
		}
	}
}
