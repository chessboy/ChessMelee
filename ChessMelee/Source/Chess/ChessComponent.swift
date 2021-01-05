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

struct TrainingRecord: Codable, Equatable {
	var inputs: [Int]
	var output: Int
}

struct AccuracyStats {
	
	var attemptedMoveCount: Int = 0
	var illegalMoveCount: Int = 0

	var currentRating: Float {
		return attemptedMoveCount == 0 ? 0 : (Float(attemptedMoveCount)-Float(illegalMoveCount))/Float(attemptedMoveCount)
	}
}

final class ChessComponent: OKComponent, OKUpdatableComponent {
    
	private var board = Board()
	private var boardNode = BoardNode()
	
	private var frame = 0
	private var lastCaptureFrame = 0
	
	private var pieceTagGenerator: Int = 0
	private var zonePointer = 0
	
	private var trainingRecords: [PieceType: [TrainingRecord]] = [:]
	private var accuracyStats: [PieceType: AccuracyStats] = [:]

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
		
		guard Constants.Chessboard.boardCount > 0 else {
			fatalError("Constants.Chessboard.boardCount must be > 0!")
		}
		
		if Constants.Training.guidedTraining {
			
			for pieceType in PieceType.allCases {
				trainingRecords[pieceType] = []

				if Constants.Training.continueTraining {
					trainingRecords[pieceType] = LocalFileManager.shared.loadTrainingRecordsFromCsvFile(for: pieceType)
					print("loaded \(trainingRecords[pieceType]!.count.abbrev) training records for \(pieceType.description)")
				}
			}
		}
		
		boardNode.position = CGPoint(x: 0, y: CGFloat(2) * Constants.Chessboard.squareDimension)
		node.addChild(boardNode)
		for pieceType in PieceType.allCases {
			accuracyStats[pieceType] = AccuracyStats()
		}
		setupBoard()
	}
		
	func setupBoard() {
	
		frame = 0
		lastCaptureFrame = 0
		pieceTagGenerator = 0
		zonePointer = 0
		
		if !Constants.Training.guidedTraining {
			accuracyStats = [:]
			for pieceType in PieceType.allCases {
				accuracyStats[pieceType] = AccuracyStats()
			}
		}
		
		(board.getPieces(color: .white) + board.getPieces(color: .black)).forEach({
			if let piece = board.getPiece(at: $0.location) {
				boardNode.removePiece(piece, from: $0.location)
			}
			board.removePiece(at: $0.location)
		})

		let pieces: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
		
		// zones
		// 1 3 5 7 9 11 13 15
		// 0 2 4 6 8 10 12 14
		func makePiece(index: Int, type: PieceType, color: PlayerColor) -> Piece {
			let tag = pieceTagGenerator
			let zoneId = (index % Constants.Chessboard.columnCount)/8 * 2 + (color == .white ? 0 : 1)
			let piece = Piece(type: type, color: color, tag: tag, zoneId: zoneId)
			//print("piece added: \(piece.description) at: \(index) in: \(zoneId)")
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
	}
							
	override func update(deltaTime seconds: TimeInterval) {
		
		if frame.isMultiple(of: 50) {
			gatherStats()
		}
		
		if Constants.Interaction.automaticBoardRefesh, frame > 500, frame.isMultiple(of: 30) {
			if frame - lastCaptureFrame > (Constants.Training.guidedTraining ? Constants.Training.epochEndNoCaptureCount : Constants.Training.epochEndNoCaptureCount/2) {
				setupBoard()
				return
			}
		}
		
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
		
	func gatherStats() {

		let labelAttrs: [AttributedStringBuilder.Attribute] = [
			.textColor(UIColor.lightGray),
			.font(UIFont.systemFont(ofSize: 18, weight: .bold))
		]

		if let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let builder = AttributedStringBuilder()
			builder.defaultAttributes = [.font(UIFont.systemFont(ofSize: 22)), .textColor(UIColor.white), .alignment(.center)]
				
			if Constants.Training.guidedTraining {
				builder
					.text("Move Counts", attributes: [.font(UIFont.systemFont(ofSize: 24, weight: .bold))])
					.newline()
					.newline(attributes: [.font(UIFont.systemFont(ofSize: 10, weight: .bold))])
			} else {
				builder
					.text("Accuracy", attributes: [.font(UIFont.systemFont(ofSize: 24, weight: .bold))])
					.newline()
					.newline(attributes: [.font(UIFont.systemFont(ofSize: 10, weight: .bold))])
			}

			for piece in PieceType.allCases {
				builder.text(piece.description, attributes: labelAttrs).text("  ", attributes: labelAttrs)

				if Constants.Training.guidedTraining {
					builder.text(trainingRecords[piece]!.count.abbrev)
				} else {
					builder.text(accuracyStats[piece]!.currentRating.formattedToPercent)
				}
				
				if piece != PieceType.allCases.last {
					builder.text("        ")
				}
			}
			
//			builder
//				.newline()
//				.newline(attributes: [.font(UIFont.systemFont(ofSize: 10, weight: .bold))])
//				.text("Accuracy: \(accuracy.formattedToPercent)")


			statsComponent.updateStats(builder.attributedString)
		}
	}
		
	func locationOfRandomPieceWithLegalMoves(color: PlayerColor) -> BoardLocation? {
		
		let piecesOfColor = board.getPieces(color: color)

		guard piecesOfColor.count > 0 else {
			return nil
		}
		
		var attemptCount = 0
		while attemptCount <= 20 {
			if let randomPiece = piecesOfColor.randomElement(), board.canPieceMove(randomPiece) {
				return randomPiece.location
			}
			attemptCount += 1
		}
		
		return nil
	}

	func locationOfPieceInZoneWithLegalMoves(color: PlayerColor) -> BoardLocation? {
		
		let piecesInZone = board.getPieces(color: color).filter({ $0.zoneId == zonePointer })
		
		guard piecesInZone.count > 0 else {
			return nil
		}
		
		var attemptCount = 0
		while attemptCount <= 20 {
			if let randomPiece = piecesInZone.randomElement(), board.canPieceMove(randomPiece) {
				//print("attemptCount: \(attemptCount)")
				return randomPiece.location
			}
			attemptCount += 1
		}
		
		return nil
	}

	func moveOnce(color: PlayerColor) {
				
		guard let fromLocation = locationOfPieceInZoneWithLegalMoves(color: color),
		   let fromPiece = board.getPiece(at: fromLocation) else {
			//print("moveOnce: error: could not get a piece to move!")
			//OctopusKit.shared.currentScene?.togglePauseByPlayer()
			return
		}
		
		accuracyStats[fromPiece.type]!.attemptedMoveCount += 1
		// boardNode.highlightSquare(location: randomFromLocation, color: .yellow)

		let inputs = BrainComponent.createInputsForBoard(board, at: fromLocation, frame: frame)
		let predictedBoardStride = brainComponent!.boardStrideForPiece(pieceType: fromPiece.type, inputs: inputs, color: color)

		guard let boardStride = predictedBoardStride else {
			if Constants.Training.highlightNoMoves {
				boardNode.highlightSquare(location: fromLocation, color: Constants.Color.noMove)
			}
			//print("no boardstride returned from inference. outputs: \(outputs.map({ $0.formattedTo2Places }))")
			accuracyStats[fromPiece.type]!.illegalMoveCount += 1
			return
		}
		
		guard fromLocation.canIncrement(by: boardStride) else {
			// trying to move off the board
			if Constants.Training.highlightIllegalMoves {
				boardNode.highlightSquare(location: fromLocation, color: Constants.Color.illegalMove)
			}
			accuracyStats[fromPiece.type]!.illegalMoveCount += 1
			return
		}
					
		let toLocation = fromLocation.incremented(by: boardStride)
		
		guard board.possibleMoveLocationsForPieceFaster(fromPiece).contains(toLocation) else {
			// trying to move to a friendly-occupied square
			if Constants.Training.highlightIllegalMoves {
				boardNode.highlightSquare(location: fromLocation, color: Constants.Color.illegalMove)
			}
			accuracyStats[fromPiece.type]!.illegalMoveCount += 1
			return
		}

		//	var moves = board.possibleMoveLocationsForPieceFaster(fromPiece)
		//	moves = moves.filter({
		//		abs(fromLocation.x - $0.x) <= fromPiece.type.visionDimension && abs(fromLocation.y - $0.y) <= fromPiece.type.visionDimension
		//	})
		//	moves.forEach({
		//		boardNode.drawLine(loc1: fromLocation, loc2: $0, color: Constants.Color.moveLineColor, thickness: 3)
		//	})
		
		if let toPiece = board.getPiece(at: toLocation) {
			if Constants.Training.highlightCaptures {
				boardNode.highlightSquare(location: toLocation, color: Constants.Color.captureMove)
			}
			lastCaptureFrame = frame
			boardNode.removePiece(toPiece, from: toLocation)
		}
		
		// moving to a legal square
		board.movePiece(from: fromLocation, to: toLocation)
		boardNode.movePiece(fromPiece, from: fromLocation, to: toLocation)

		if fromPiece.type == .pawn {
			// check promotion
			if !toLocation.canIncrement(by: BoardStride(x: 0, y: color == .white ? 1 : -1)) {
				lastCaptureFrame = frame
				if Constants.Training.highlightPromotions {
					boardNode.highlightSquare(location: toLocation, color: Constants.Color.promotionMove)
				}
				board.removePiece(at: toLocation)
				boardNode.removePiece(fromPiece, from: toLocation)

				let promotedPieceType = PieceType.possiblePawnPromotionResultingTypes().randomElement() ?? .queen
				let promotedPiece = Piece(type: promotedPieceType, color: color, tag: pieceTagGenerator, zoneId: fromPiece.zoneId)
				pieceTagGenerator += 1
				board.setPiece(promotedPiece, at: toLocation)
				boardNode.addPiece(promotedPiece, at: toLocation)
			}
		}
	}
	
	func saveTrainingRecords() {
		for pieceType in PieceType.allCases {
			let trainingRecordsForPiece = trainingRecords[pieceType]!
			//LocalFileManager.shared.saveTrainingRecordsToJsonFile(trainingRecordsForPiece, for: pieceType)
			LocalFileManager.shared.saveTrainingRecordsToCsvFile(trainingRecordsForPiece, for: pieceType)
		}
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
					
					var moves = board.possibleMoveLocationsForPieceFaster(piece)
					moves = moves.filter({
						abs(boardLoc.x - $0.x) <= piece.type.visionDimension && abs(boardLoc.y - $0.y) <= piece.type.visionDimension
					})

					print("moves at \(boardLoc.index) for \(piece.color) \(piece.type.char) are \(moves)")
					moves.forEach({
						boardNode.drawLine(loc1: boardLoc, loc2: $0, color: .red, thickness: 6)
					})
					
					if shiftDown {
						let _ = BrainComponent.createInputsForBoard(board, at: boardLoc, frame: frame, debug: true)
					}
				}
			}
		}
	}
	
	// for generating training data sets
	func moveOnceRandomly(color: PlayerColor) {
		
		if let fromLocation = locationOfPieceInZoneWithLegalMoves(color: color),
		   let fromPiece = board.getPiece(at: fromLocation) {
			
			var moves = board.possibleMoveLocationsForPieceFaster(fromPiece)
			
			// all legal moves within the piece's vision
			moves = moves.filter({
				abs(fromLocation.x - $0.x) <= fromPiece.type.visionDimension && abs(fromLocation.y - $0.y) <= fromPiece.type.visionDimension
			}).sorted(by: { (loc1, loc2) -> Bool in
				return abs(fromLocation.x - loc1.x) + abs(fromLocation.y - loc1.y) > abs(fromLocation.x - loc2.x) + abs(fromLocation.y - loc2.y)
			})
		
			// all captures within those moves
			let captures = moves.filter({ location in
				board.getPiece(at: location)?.color == color.opposite
			}).sorted(by: { (loc1, loc2) -> Bool in
				// TODO: use piece value in the future when more than just friend|enemy is sent via inputs
				return abs(fromLocation.x - loc1.x) + abs(fromLocation.y - loc1.y) > abs(fromLocation.x - loc2.x) + abs(fromLocation.y - loc2.y)
			})

			guard let toLocation = captures.count > 0 ? captures[frame % captures.count] : moves.count > 0 ? moves[frame % moves.count] : nil else {
				print("-•- Houston, we have a problem")
				return
			}
							
			let visionDimension = fromPiece.type.visionDimension
			let visionDimensionOver2 = visionDimension/2
			let centerIndex = (visionDimension * visionDimension) / 2
			
			let inputs = BrainComponent.createInputsForBoard(board, at: fromLocation, frame: frame)
			let stride = fromLocation.strideTo(location: toLocation)
			let inverter = fromPiece.color == .white ? 1 : -1

			let rank = -stride.y * inverter + visionDimensionOver2
			let file = stride.x * inverter + visionDimensionOver2
			var outputIndex = rank*visionDimension + file
			if outputIndex >= centerIndex {
				outputIndex -= 1
			}
						
			let trainingRecord = TrainingRecord(inputs: inputs, output: outputIndex)
			let allInputs: [[Int]] = trainingRecords[fromPiece.type]!.map({ $0.inputs })
			if !allInputs.contains(trainingRecord.inputs) {
				trainingRecords[fromPiece.type]!.append(trainingRecord)
			}
			
			//	print("\(color) \(fromPiece.type.description), from: \(randomFromLocation), to: \(randomToLocation), stride: \(stride), outputs: \(xOutput),\(yOutput)")
			//	print(inputs)
			//	print(outputs)
			//	print()
			
			if let toPiece = board.getPiece(at: toLocation) {
				lastCaptureFrame = frame
				boardNode.removePiece(toPiece, from: toLocation)
			}
			
			board.movePiece(from: fromLocation, to: toLocation)
			boardNode.movePiece(fromPiece, from: fromLocation, to: toLocation)

			if fromPiece.type == .pawn {

				if !toLocation.canIncrement(by: BoardStride(x: 0, y: color == .white ? 1 : -1)) {
					
					board.removePiece(at: toLocation)
					boardNode.removePiece(fromPiece, from: toLocation)
					let promotedPieceType = PieceType.possiblePawnPromotionResultingTypes().randomElement() ?? .queen
					let promotedPiece = Piece(type: promotedPieceType, color: color, tag: pieceTagGenerator, zoneId: fromPiece.zoneId)
					pieceTagGenerator += 1
					board.setPiece(promotedPiece, at: toLocation)
					boardNode.addPiece(promotedPiece, at: toLocation)
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
