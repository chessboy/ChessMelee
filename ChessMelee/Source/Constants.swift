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
		// you may change these
		static let boardCount = 6
		static let rowCount = 12
		static let squareDimension: CGFloat = min(
			ScreenInspector.shared.width/(CGFloat(boardCount)*8),
			(ScreenInspector.shared.height - (Interaction.statsHeight + 50))/CGFloat(rowCount))

		// you shouldn't need to change these
		static let zoneCount = boardCount * 2
		static let columnCount = zoneCount * 4
		static let squareCount = columnCount * rowCount
		static let showSquareIndices = false
	}
	
	struct Interaction {
		static let automaticBoardRefesh = true
		static let statsHeight: CGFloat = 150
	}

	struct Window {
		// you may need to change these depending on settings above
		static let width: CGFloat = Constants.Chessboard.squareDimension * CGFloat(Constants.Chessboard.columnCount)
		static let height: CGFloat = Constants.Chessboard.squareDimension * CGFloat(Constants.Chessboard.rowCount) + Interaction.statsHeight
	}
	
	struct Animation {
		static let duration: TimeInterval = 0.33
		static let highlightMoves = true
		static let highlightCaptures = false
		static let highlightPromotions = false
		static let highlightNoMoves = true
		static let highlightIllegalMoves = true
	}
		
	struct Training {
		static let guidedTraining = false
		static let continueTraining = guidedTraining && false
		static let epochEndNoCaptureCount = 200
	}
	
	struct Color {
		static let lightSquareColor = SKColor(red: 0.612, green: 0.648, blue: 0.657, alpha: 1)
		static let darkSquareColor = SKColor(red: 0.324, green: 0.432, blue: 0.495, alpha: 1)

		static let noMove = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.85)
		static let illegalMove = SKColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.85)
		static let captureMove = SKColor(red: 0.2, green: 1, blue: 0.2, alpha: 0.85)
		static let promotionMove = SKColor(red: 1, green: 1, blue: 0.2, alpha: 0.85)

		static let moveLineColor = SKColor(red: 0, green: 0.3, blue: 1, alpha: 1)
	}
}
