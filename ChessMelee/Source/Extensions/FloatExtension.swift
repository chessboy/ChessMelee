//
//  FloatExtension.swift
//  ChessMelee
//
//  Created by Rob Silverman on 12/29/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import Foundation

extension Float {
	
	/* Ensures that the float value stays between the given values, inclusive.
	*/
	func clamped(_ v1: Float, _ v2: Float) -> Float {
		let min = v1 < v2 ? v1 : v2
		let max = v1 > v2 ? v1 : v2
		return self < min ? min : (self > max ? max : self)
	}
	
	/**
	* Ensures that the float value stays between the given values, inclusive.
	*/
	mutating func clamp(_ v1: Float, _ v2: Float) -> Float {
		self = clamped(v1, v2)
		return self
	}

	var formattedTo2Places: String { return
		String(format: "%.2f", locale: Locale.current, self)
	}
	
	var formattedTo3Places: String { return
		String(format: "%.3f", locale: Locale.current, self)
	}
	
	var formattedTo4Places: String { return
		String(format: "%.4f", locale: Locale.current, self)
	}

	var formattedToPercent: String { return
		String(format: "%.1f", locale: Locale.current, self.clamped(0, 1) * 100) + "%"
	}

	var formattedToPercentNoDecimal: String { return
		String(format: "%.0f", locale: Locale.current, self.clamped(0, 1) * 100) + "%"
	}

	var cgFloat: CGFloat { return CGFloat(self) }
	
	var unsigned: Float { return abs(self) }
	
	var sigmoid: Float {
		return 1 / (1 + exp(-self))
	}
	
	var sigmoidBool: Float {
		return sigmoid >= 0.5 ? 1 : 0
	}
	
	static func indexOfMax(outputs: [Float], threshold: Float) -> Int? {
		
		if let max = outputs.max(), max >= threshold {
			
			let allIndicesOfMax = outputs.allIndices(of: max)
			guard allIndicesOfMax.count > 0 else {
				print("indexOfMax: error: there should be at least one max here")
				return nil
			}
			guard let randomIndexOfMax = allIndicesOfMax.randomElement() else {
				print("indexOfMax: error: could not get a random index for max")
				return nil
			}
			return randomIndexOfMax
		}
		
		return nil
	}
}
