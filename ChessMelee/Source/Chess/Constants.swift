//
//  Constants.swift
//  ChessMelee
//
//  Created by Rob Silverman on 12/31/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import Foundation
import SpriteKit

struct Constants {
	
	struct Chessboard {
		static let zoneCount = 16
		static let columnCount = zoneCount * 4
		static let rowCount = 12
		static let squareCount = columnCount * rowCount
		static let squareDimension: CGFloat = 1200/32
	}

	struct Animation {
		static let duration: TimeInterval = 0.33
	}
	
	struct Vision {
		static let dimension = 5
	}
	
	struct Training {
		static let guidedTraining = false
		
		static let highlightCaptures = false
		static let highlightPromotions = true
		static let highlightNoMoves = true
		static let highlightIllegalMoves = true
	}

	struct NeuralNetwork {
		static let visibleSquareCount = (Vision.dimension * Vision.dimension) - 1 // 24 squares for 5x5 grid not including origin
		static let inputCount = visibleSquareCount
	}
	
	struct Color {
		static let whiteSquareColor = SKColor(red: 92.8/255, green: 121.6/255, blue: 139.2/255, alpha: 1)
		static let blackSquareColor = SKColor(red: 174.4/255, green: 183.2/255, blue: 186.4/255, alpha: 1)

		static let noMove = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.85)
		static let illegalMove = SKColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.85)
		static let captureMove = SKColor(red: 0.2, green: 1, blue: 0.2, alpha: 0.85)
		static let promotionMove = SKColor(red: 1, green: 1, blue: 0.2, alpha: 0.85)

		static let moveLineColor = SKColor(red: 0, green: 0.3, blue: 1, alpha: 1)
	}
}
