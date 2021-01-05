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
		// you may changes these
		static let boardCount = 6
		static let rowCount = 12
		static let squareDimension: CGFloat = 37.5

		// you shouldn't need to change these
		static let zoneCount = boardCount * 2
		static let columnCount = zoneCount * 4
		static let squareCount = columnCount * rowCount
		static let showSquareIndices = false
	}
	
	struct Interaction {
		static let automaticBoardRefesh = true
	}

	struct Window {
		// you may need to change these depending on settings above
		static let width: CGFloat = Constants.Chessboard.squareDimension * CGFloat(Constants.Chessboard.columnCount)
		static let height: CGFloat = 600
	}
	
	struct Animation {
		static let duration: TimeInterval = 0.33
	}
		
	struct Training {
		static let guidedTraining = false
		static let continueTraining = guidedTraining && false
		static let epochEndNoCaptureCount = 200
		static let highlightCaptures = false
		static let highlightPromotions = true
		static let highlightNoMoves = true
		static let highlightIllegalMoves = true
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
