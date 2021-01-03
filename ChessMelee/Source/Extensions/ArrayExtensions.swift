//
//  ArrayExtensions.swift
//  ChessMelee
//
//  Created by Rob Silverman on 1/1/21.
//  Copyright © 2021 Robert Silverman. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
	
	func allIndices(of value: Element) -> [Index] {
		return indices.filter { self[$0] == value }
	}
	
	func chunked(into size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}


