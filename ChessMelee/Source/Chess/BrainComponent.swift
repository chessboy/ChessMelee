//
//  BrainComponent.swift
//  ChessMelee
//
//  Created by Rob Silverman on 12/29/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import Foundation
import SpriteKit
import OctopusKit
import CoreML

final class BrainComponent: OKComponent {
				
	var pawnMoveModel: PawnMoveModel?
	var rookMoveModel: RookMoveModel?
	var knightMoveModel: KnightMoveModel?
	var bishopMoveModel: BishopMoveModel?
	var queenMoveModel: QueenMoveModel?
	var kingMoveModel: KingMoveModel?
	
	override func didAddToEntity(withNode node: SKNode) {
		
		do {
			pawnMoveModel = try PawnMoveModel(configuration: MLModelConfiguration())
			rookMoveModel = try RookMoveModel(configuration: MLModelConfiguration())
			knightMoveModel = try KnightMoveModel(configuration: MLModelConfiguration())
			bishopMoveModel = try BishopMoveModel(configuration: MLModelConfiguration())
			queenMoveModel = try QueenMoveModel(configuration: MLModelConfiguration())
			kingMoveModel = try KingMoveModel(configuration: MLModelConfiguration())
		} catch let error {
			print("could not create an ML model: error: \(error.localizedDescription)")
		}
	}
	
	func boardStrideForPiece(pieceType: Piece.PieceType, inputs: [Float], color: PlayerColor) -> BoardStride? {
		
		switch pieceType {
		case .pawn: return boardStrideForPawn(input: PawnMoveModelInput.create(inputs: inputs), color: color)
		case .rook: return boardStrideForRook(input: RookMoveModelInput.create(inputs: inputs), color: color)
		case .knight: return boardStrideForKnight(input: KnightMoveModelInput.create(inputs: inputs), color: color)
		case .bishop: return boardStrideForBishop(input: BishopMoveModelInput.create(inputs: inputs), color: color)
		case .queen: return boardStrideForQueen(input: QueenMoveModelInput.create(inputs: inputs), color: color)
		case .king: return boardStrideForKing(input: KingMoveModelInput.create(inputs: inputs), color: color)
		}
	}
	
	func boardStrideForPawn(input: PawnMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try pawnMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for pawn: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForRook(input: RookMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try rookMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for rook: \(error.localizedDescription)")
		}

		return nil
	}

	func boardStrideForKnight(input: KnightMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try knightMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for knight: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForBishop(input: BishopMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try bishopMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for bishop: \(error.localizedDescription)")
		}

		return nil
	}

	func boardStrideForQueen(input: QueenMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try queenMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for queen: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForKing(input: KingMoveModelInput, color: PlayerColor) -> BoardStride? {
				
		do {
			if let prediction = try kingMoveModel?.prediction(input: input) {
				return outputIndexToStride(index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for king: \(error.localizedDescription)")
		}

		return nil
	}

	func outputIndexToStride(index: Int, color: PlayerColor) -> BoardStride {
		
		let visionDimension = Constants.Vision.dimension
		let visionDimensionOver2 = Constants.Vision.dimension / 2
		let centerIndex = (visionDimension * visionDimension) / 2

		let adjustForCenter = index < centerIndex ? 0 : 1
		var x = ((index+adjustForCenter) % visionDimension) - visionDimensionOver2
		var y = visionDimensionOver2 - ((index+adjustForCenter) / visionDimension)

		let inverter = color == .white ? 1 : -1
		x *= inverter
		y *= inverter
		
		//print("index: \(index), color: \(color), x: \(x), y: \(y)")
		
		return BoardStride(x: x, y: y)
	}
}

extension Board {
	
	func createInputs(at location: BoardLocation, debug: Bool = false) -> [Float] {
		
		guard let piece = getPiece(at: location) else {
			return []
		}
		
		let stride = [-2, -1, 0, 1, 2]
		let yStride = piece.color == .black ? stride : stride.reversed()
		let xStride = piece.color == .white ? stride : stride.reversed()

		var inputs: [Float] = []
		// print(inputs)
		
		var asciiBoard = "" // only needed for debugging
		
		var inputIndex = 0
		for y: Int in yStride {
			for x in xStride {
				
				if x == 0, y == 0 {
					asciiBoard += "• "
				}
				else {
					let stride = BoardStride(x: x, y: y)
					if location.canIncrement(by: stride) {
						let testLocation = BoardLocation(x: location.x + x, y: location.y + y)
						if let testPiece = getPiece(at: testLocation) {
							let friendOrEnemy: [Float] = testPiece.color == piece.color ? [1] : [2]
							asciiBoard += "\(testPiece.asciiChar) "
							inputs += friendOrEnemy
							
						} else {
							// empty
							asciiBoard += "- "
							inputs += [0]
						}
					} else {
						// out of bounds
						asciiBoard += "# "
						inputs += [-1]
					}
				}
				inputIndex += 1
			}
			if y != (yStride.last ?? -1) {
				asciiBoard += "\n"
			}
		}
		
		if debug {
			print("piece: \(piece.asciiChar), location: \(location.index), x: \(location.x), y: \(location.y)")
			print("\(asciiBoard)")
			print("inputs: \(inputs.map({Int($0)})) (\(inputs.count))")
			print()
		}
		
		return inputs
	}
}

extension Piece {
	
	var asciiChar: Character {
		switch type {
		case .rook:
			return color == .white ? "R" : "r"
		case .knight:
			return color == .white ? "N" : "n"
		case .bishop:
			return color == .white ? "B" : "b"
		case .queen:
			return color == .white ? "Q" : "q"
		case .king:
			return color == .white ? "K" : "k"
		case .pawn:
			return color == .white ? "P" : "p"
		}
	}
}


extension PawnMoveModelInput {
	
	static func create(inputs: [Float]) -> PawnMoveModelInput {
		return PawnMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}

extension RookMoveModelInput {
	
	static func create(inputs: [Float]) -> RookMoveModelInput {
		return RookMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}

extension KnightMoveModelInput {
	
	static func create(inputs: [Float]) -> KnightMoveModelInput {
		return KnightMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}

extension BishopMoveModelInput {
	
	static func create(inputs: [Float]) -> BishopMoveModelInput {
		return BishopMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}

extension QueenMoveModelInput {
	
	static func create(inputs: [Float]) -> QueenMoveModelInput {
		return QueenMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}
	
extension KingMoveModelInput {
	
	static func create(inputs: [Float]) -> KingMoveModelInput {
		return KingMoveModelInput(inputs_0: Double(inputs[0]), inputs_1: Double(inputs[1]), inputs_2: Double(inputs[2]), inputs_3: Double(inputs[3]), inputs_4: Double(inputs[4]), inputs_5: Double(inputs[5]), inputs_6: Double(inputs[6]), inputs_7: Double(inputs[7]), inputs_8: Double(inputs[8]), inputs_9: Double(inputs[9]), inputs_10: Double(inputs[10]), inputs_11: Double(inputs[11]), inputs_12: Double(inputs[12]), inputs_13: Double(inputs[13]), inputs_14: Double(inputs[14]), inputs_15: Double(inputs[15]), inputs_16: Double(inputs[16]), inputs_17: Double(inputs[17]), inputs_18: Double(inputs[18]), inputs_19: Double(inputs[19]), inputs_20: Double(inputs[20]), inputs_21: Double(inputs[21]), inputs_22: Double(inputs[22]), inputs_23: Double(inputs[23]))
	}
}

