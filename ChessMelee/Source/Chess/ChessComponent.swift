//
//  ChessComponent.swift
//  ChessViz
//
//  Created by Robert Silverman on 3/21/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

struct TrainingRecord: Codable {
	var pieceType: Piece.PieceType
	var inputs: [Float]
	var output: Int
}

final class ChessComponent: OKComponent, OKUpdatableComponent {
    
	public private(set) var currentEpoch = 0

	private var board = Board()
	private var boardNode = BoardNode()
	private var frame = 0
	private var ticksPerEpoch = 0
	private var pieceTagGenerator: Int = 0
	private var zonePointer = 0

	lazy var brainComponent = coComponent(BrainComponent.self)

    override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		BrainComponent.self
		]
    }
		
	//	 8 --> 4
	//	10 --> 3
	//	12 --> 2
	//  14 --> 0
	override func didAddToEntity(withNode node: SKNode) {
		boardNode.position = CGPoint(x: 0, y: CGFloat(2) * Constants.Chessboard.squareDimension)
		node.addChild(boardNode)
		setupBoard()
	}
		
	func setupBoard() {
	
		frame = 0
		pieceTagGenerator = 0
		
		(board.getPieces(color: .white) + board.getPieces(color: .black)).forEach({
			if let piece = board.getPiece(at: $0.location) {
				boardNode.removePiece(piece, from: $0.location)
			}
			board.removePiece(at: $0.location)
		})

		let pieces: [Piece.PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
		
		// zones
		// 1 3 5 7 9 11 13 15
		// 0 2 4 6 8 10 12 14
		func makePiece(index: Int, type: Piece.PieceType, color: PlayerColor) -> Piece {
			
			let tag = pieceTagGenerator
			let zoneId = (index % Constants.Chessboard.columnCount)/(Constants.Chessboard.zoneCount/2) * 2 + (color == .white ? 0 : 1)
			let piece = Piece(type: type, color: color, tag: tag, zoneId: zoneId)
			pieceTagGenerator += 1
			
			return piece
		}
		
		// white bottom row
		for i in 0...Constants.Chessboard.columnCount - 1 {
			let piece = makePiece(index: i, type: pieces[i%8], color: .white)
			board.setPiece(piece, at: BoardLocation(index: i))
		}

		// white pawn row
		for i in Constants.Chessboard.columnCount...Constants.Chessboard.columnCount*2 - 1 {
			let piece = makePiece(index: i, type: .pawn, color: .white)
			board.setPiece(piece, at: BoardLocation(index: i))
		}

		// black bottom row
		for i in Constants.Chessboard.squareCount - Constants.Chessboard.columnCount...Constants.Chessboard.squareCount - 1 {
			let piece = makePiece(index: i, type: pieces[i%8], color: .black)
			board.setPiece(piece, at: BoardLocation(index: i))
		}

		// black pawn row
		for i in Constants.Chessboard.squareCount - Constants.Chessboard.columnCount*2...Constants.Chessboard.squareCount - Constants.Chessboard.columnCount - 1 {
			let piece = makePiece(index: i, type: .pawn, color: .black)
			board.setPiece(piece, at: BoardLocation(index: i))
		}

		renderBoard()
		
//		print()
//		print("current epoch: \(currentEpoch), ticksPerCurrentEpoch: \(ticksPerEpoch.abbrev)")
	}
					
//	var currentPieceRankings: [Piece.PieceType: [Float]] {
//		return [:]
//	}
	
	override func update(deltaTime seconds: TimeInterval) {
		
		if frame.isMultiple(of: 50) {
			gatherStats()
		}
		
		// TODO: add empty board check
		
		if Constants.Training.guidedTraining {
			moveOnceRandomly(color: .white)
			zonePointer = (zonePointer + 1) % Constants.Chessboard.zoneCount
			moveOnceRandomly(color: .black)
			zonePointer = (zonePointer + 1) % Constants.Chessboard.zoneCount
		} else {
			moveOnce(color: .white)
			zonePointer = (zonePointer + 1) % Constants.Chessboard.zoneCount
			moveOnce(color: .black)
			zonePointer = (zonePointer + 1) % Constants.Chessboard.zoneCount
		}
		frame += 1
	}
	
	func forceNextGeneration() {
		frame = Int.max
	}
	
	func gatherStats() {
		/*
		let rankings = currentPieceRankings
		let attempedMoveCount = smartPieces.reduce(Float.zero) { $0 + Float($1.attemptedMoveCount) }
		let successfulMoveCount = smartPieces.reduce(Float.zero) { $0 + Float($1.successfulMoveCount) }
		let accuracy = attempedMoveCount == 0 ? 0 : successfulMoveCount/attempedMoveCount

		if let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let builder = AttributedStringBuilder()
			builder.defaultAttributes = [.font(UIFont.systemFont(ofSize: 22)), .textColor(UIColor.white), .alignment(.center)]
				
			for piece in Piece.PieceType.allCases {
				builder
					.text(piece.description)
					.text(": ")
					.text(rankings[piece]![0].rating.formattedTo2Places)
					.text(" zone (\(rankings[piece]![0].zoneId))")

				if piece != Piece.PieceType.allCases.last {
					builder.text("  |  ")
				}
			}
			
			builder
				.newline()
				.newline(attributes: [.font(UIFont.systemFont(ofSize: 10, weight: .bold))])
				.text("Accuracy: \(accuracy.formattedToPercent)")


			statsComponent.updateStats(builder.attributedString)
		}
		*/
	}
		
	func locationOfPieceInZoneWithLegalMoves(color: PlayerColor) -> BoardLocation? {
		
		let piecesInZone = board.getPieces(color: color).filter({ $0.zoneId == zonePointer })
		
		guard piecesInZone.count > 0 else {
			return nil
		}
		
		var attemptCount = 0
		while attemptCount <= 20 {
			if let randomPiece = piecesInZone.randomElement(), board.possibleMoveLocationsForPiece(atLocation: randomPiece.location).count > 0 {
				//print("attemptCount: \(attemptCount)")
				return randomPiece.location
			}
			attemptCount += 1
		}
		
		return nil
	}

	func moveOnce(color: PlayerColor) {
				
		guard let randomFromLocation = locationOfPieceInZoneWithLegalMoves(color: color),
		   let fromPiece = board.getPiece(at: randomFromLocation) else {
			//print("moveOnce: error: could not get a piece to move!")
			//OctopusKit.shared.currentScene?.togglePauseByPlayer()
			return
		}
		
		// fromPiece.attemptedMoveCount += 1
		// boardNode.highlightSquare(location: randomFromLocation, color: .yellow)

		let inputs = board.createInputs(at: randomFromLocation)
		let predictedBoardStride = brainComponent!.boardStrideForPiece(pieceType: fromPiece.type, inputs: inputs, color: color)

		guard let boardStride = predictedBoardStride else {
			boardNode.highlightSquare(location: randomFromLocation, color: Constants.Color.noMove)
			//print("no boardstride returned from inference. outputs: \(outputs.map({ $0.formattedTo2Places }))")
			//fromSmartPiece.illegalMoveCount += 1
			return
		}
		
		guard randomFromLocation.canIncrement(by: boardStride) else {
			// trying to move off the board
			boardNode.highlightSquare(location: randomFromLocation, color: Constants.Color.illegalMove)
			//fromPiece.illegalMoveCount += 1
			return
		}
					
		let toLocation = randomFromLocation.incremented(by: boardStride)
		
		guard board.possibleMoveLocationsForPiece(atLocation: randomFromLocation).contains(toLocation) else {
			// trying to move to a friendly-occupied square
			boardNode.highlightSquare(location: randomFromLocation, color: Constants.Color.illegalMove)
			//fromPiece.illegalMoveCount += 1
			return
		}

		if let toPiece = board.getPiece(at: toLocation) {
//			boardNode.highlightSquare(location: toLocation, color: Constants.Color.captureMove)
			boardNode.removePiece(toPiece, from: toLocation)
		}
		
		// moving to a legal square
		board.movePiece(from: randomFromLocation, to: toLocation)
		boardNode.movePiece(fromPiece, from: randomFromLocation, to: toLocation)
		//fromPiece.successfulMoveCount += 1

		if fromPiece.type == .pawn {
			// check promotion
			if !toLocation.canIncrement(by: BoardStride(x: 0, y: color == .white ? 1 : -1)) {
				boardNode.highlightSquare(location: toLocation, color: Constants.Color.promotionMove)
				board.removePiece(at: toLocation)
				boardNode.removePiece(fromPiece, from: toLocation)

				let promotedPieceType = Piece.PieceType.possiblePawnPromotionResultingTypes().randomElement() ?? .queen
				let promotedPiece = Piece(type: promotedPieceType, color: color, tag: pieceTagGenerator, zoneId: fromPiece.zoneId)
				pieceTagGenerator += 1
				board.setPiece(promotedPiece, at: toLocation)
				boardNode.addPiece(promotedPiece, at: toLocation)
			}
		}
	}
		
	var hasOneSideWon: Bool {
		return board.getPieces(color: .white).count + board.getPieces(color: .black).count <= 4
	}
	
	func touchDown(point: CGPoint, rightMouse: Bool = false, commandDown: Bool = false, shiftDown: Bool = false, optionDown: Bool = false, clickCount: Int = 1) {
		
		let adjustedPoint = CGPoint(x: point.x - boardNode.position.x, y: point.y - boardNode.position.y)
		if let squareNode = boardNode.nodes(at: adjustedPoint).last as? SKSpriteNode,
			let squareName = squareNode.name {
			if let index = Int(squareName) {
				let boardLoc = BoardLocation(index: index)
				if let piece = board.getPiece(at: boardLoc) {
					
					if rightMouse {
						board.removePiece(at: boardLoc)
						boardNode.removePiece(piece, from: boardLoc)
						return
					}
					
					let moves = board.possibleMoveLocationsForPiece(atLocation: boardLoc)
					print("moves at \(boardLoc.index) for \(piece.color) \(piece.type.char) are \(moves)")
					moves.forEach({
						boardNode.drawLine(loc1: boardLoc, loc2: $0, color: Constants.Color.moveLineColor, thickness: 4)
					})
					
					if shiftDown {
						let _ = board.createInputs(at: boardLoc, debug: true)
					}
				}
			}
		}
	}
		
	// pawn 	3x2
	// knight	5x5
	// bishop	7x7
	// queen	7x7
	// rook		7x7
	// king		3x3
	
	var trainingRecords: [Piece.PieceType: [TrainingRecord]] = [:]
	
	func moveOnceRandomly(color: PlayerColor) {
		
		if let randomFromLocation = locationOfPieceInZoneWithLegalMoves(color: color),
		   let fromPiece = board.getPiece(at: randomFromLocation) {
			
			var moves = board.possibleMoveLocationsForPiece(atLocation: randomFromLocation)
			moves = moves.filter({
				abs(randomFromLocation.x - $0.x) <= 5 && abs(randomFromLocation.y - $0.y) <= 5
			})
			
			let captures = moves.filter({ location in
				board.getPiece(at: location)?.color == color.opposite
			}).sorted(by: { (loc1, loc2) -> Bool in
				return board.getPiece(at: loc1)?.value ?? 0 > board.getPiece(at: loc2)?.value ?? 0
			})
						
			if let randomToLocation = captures.first ?? moves.randomElement() {
				
				if Constants.Training.guidedTraining {
					let inputs = board.createInputs(at: randomFromLocation)
					let stride = randomFromLocation.strideTo(location: randomToLocation)
					let inverter = fromPiece.color == .white ? 1 : -1

					let visionDimension = Constants.Vision.dimension
					let centerIndex = (visionDimension * visionDimension) / 2

					var outputIndex = -(stride.y * inverter-2)*visionDimension + (stride.x * inverter + 2)
					if outputIndex >= centerIndex {
						outputIndex -= 1
					}
					
					if trainingRecords[fromPiece.type] == nil {
						trainingRecords[fromPiece.type] = []
					}
					trainingRecords[fromPiece.type]!.append(TrainingRecord(pieceType: fromPiece.type, inputs: inputs, output: outputIndex))
					
	//				print("\(color) \(fromPiece.type.description), from: \(randomFromLocation), to: \(randomToLocation), stride: \(stride), outputs: \(xOutput),\(yOutput)")
	//				print(inputs)
	//				print(outputs)
	//				print()
				}
				
				if let toPiece = board.getPiece(at: randomToLocation) {
					boardNode.removePiece(toPiece, from: randomToLocation)
				}
				
				board.movePiece(from: randomFromLocation, to: randomToLocation)
				boardNode.movePiece(fromPiece, from: randomFromLocation, to: randomToLocation)

				if fromPiece.type == .pawn {

					if !randomToLocation.canIncrement(by: BoardStride(x: 0, y: color == .white ? 1 : -1)) {
						
						board.removePiece(at: randomToLocation)
						boardNode.removePiece(fromPiece, from: randomToLocation)
						let promotedPieceType = Piece.PieceType.possiblePawnPromotionResultingTypes().randomElement() ?? .queen
						let promotedPiece = Piece(type: promotedPieceType, color: color, tag: pieceTagGenerator, zoneId: fromPiece.zoneId)
						pieceTagGenerator += 1
						board.setPiece(promotedPiece, at: randomToLocation)
						boardNode.addPiece(promotedPiece, at: randomToLocation)
					}
				}
			}
		}
	}
		
	func renderBoard() {
		boardNode.removeAllPieces()
        for sourceLocation in BoardLocation.all {
            if let piece = board.getPiece(at: sourceLocation) {
				boardNode.addPiece(piece, at: sourceLocation)
			}
		}
	}
}
