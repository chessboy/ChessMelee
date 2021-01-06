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
	
	func boardStrideForPiece(pieceType: PieceType, inputs: [Int], color: PlayerColor) -> BoardStride? {
		
		let inputsAsDoubles = inputs.map({ Double($0) })
		
		switch pieceType {
		case .pawn: return boardStrideForPawn(input: PawnMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		case .rook: return boardStrideForRook(input: RookMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		case .knight: return boardStrideForKnight(input: KnightMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		case .bishop: return boardStrideForBishop(input: BishopMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		case .queen: return boardStrideForQueen(input: QueenMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		case .king: return boardStrideForKing(input: KingMoveModelInput.create(inputs: inputsAsDoubles), color: color)
		}
	}
	
	func boardStrideForPawn(input: PawnMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try pawnMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.pawn.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for pawn: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForRook(input: RookMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try rookMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.rook.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for rook: \(error.localizedDescription)")
		}

		return nil
	}

	func boardStrideForKnight(input: KnightMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try knightMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.knight.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for knight: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForBishop(input: BishopMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try bishopMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.bishop.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for bishop: \(error.localizedDescription)")
		}

		return nil
	}

	func boardStrideForQueen(input: QueenMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try queenMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.queen.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for queen: \(error.localizedDescription)")
		}

		return nil
	}
	
	func boardStrideForKing(input: KingMoveModelInput, color: PlayerColor) -> BoardStride? {
		do {
			if let prediction = try kingMoveModel?.prediction(input: input) {
				return BrainComponent.outputIndexToStride(visionDimension: PieceType.king.visionDimension, index: Int(prediction.output), color: color)
			}
		} catch let error {
			print("error making prediction for king: \(error.localizedDescription)")
		}

		return nil
	}
}

extension BrainComponent {
	
	static func outputIndexToStride(visionDimension: Int, index: Int, color: PlayerColor) -> BoardStride {
		
		let visionDimensionOver2 = visionDimension / 2
		let centerIndex = (visionDimension * visionDimension) / 2

		let adjustForCenter = index < centerIndex ? 0 : 1
		var x = ((index+adjustForCenter) % visionDimension) - visionDimensionOver2
		var y = visionDimensionOver2 - ((index+adjustForCenter) / visionDimension)

		let inverter = color == .white ? 1 : -1
		x *= inverter
		y *= inverter
		
		//print("visionDimension: \(visionDimension), index: \(index), color: \(color), x: \(x), y: \(y)")
		
		return BoardStride(x: x, y: y)
	}
	
	/**
	 -1: out of bounds
	  0: empty square
	  1: pawn of same color
	  2: rook of same color
	  3: knight of same color
	  4: bishop of same color
	  5: queen of same color
	  6: king of same color
	  7: pawn of opposite color
	  8: rook of opposite color
	  9: knight of opposite color
	 10: bishop of opposite color
	 11: queen of opposite color
	 12: king of opposite color
	*/
	static func createInputsForBoard(_ board: Board, at location: BoardLocation, frame: Int, debug: Bool = false) -> [Int] {
		
		guard let piece = board.getPiece(at: location) else {
			return []
		}
		
		let visionDimensionOver2 = piece.type.visionDimension/2
		let visionStride = Array(stride(from: -visionDimensionOver2, through: visionDimensionOver2, by: 1))

		let yStride = piece.color == .black ? visionStride : visionStride.reversed()
		let xStride = piece.color == .white ? visionStride : visionStride.reversed()

		var inputs: [Int] = []
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
						if let testPiece = board.getPiece(at: testLocation) {
							asciiBoard += "\(testPiece.asciiChar) "
							if Constants.Training.useNewerModels {
								inputs.append(testPiece.type.inputValue + (testPiece.color == piece.color ? 0 : 6))
							}
							else {
								inputs.append(testPiece.color == piece.color ? 1 : 2)
							}
						} else {
							// empty
							asciiBoard += "- "
							inputs.append(0)
						}
					} else {
						// out of bounds
						asciiBoard += "# "
						inputs.append(-1)
					}
				}
				inputIndex += 1
			}
			if y != (yStride.last ?? -1) {
				asciiBoard += "\n"
			}
		}
		
		let picker = frame % piece.type.moveSquareMaxForVision
		inputs.append(picker)
		
		if debug {
			print("piece: \(piece.color) \(piece.asciiChar), location: \(location.index), x: \(location.x), y: \(location.y), picker: \(picker)")
			print("\(asciiBoard)")
			print("inputs: \(inputs.map({Int($0)})) (\(inputs.count))")
			print()
		}
		
		return inputs
	}
}

extension Board {
	
	func canPieceMove(_ piece: Piece) -> Bool {
		let visionDimension = piece.type.visionDimension
		let visionDimensionOver2 = visionDimension/2
		let visionStride = Array(stride(from: -visionDimensionOver2, through: visionDimensionOver2, by: 1))

		for y: Int in visionStride {
			for x in visionStride {
				let toLocation = piece.location + BoardLocation(x: x, y: y)
				if piece.movement.canPieceMove(from: piece.location, to: toLocation, board: self) {
					return true
				}
			}
		}
		return false
	}
	
	func possibleMoveLocationsForPieceUsingVision(_ piece: Piece) -> [BoardLocation] {
		let visionDimension = piece.type.visionDimension
		let visionDimensionOver2 = visionDimension/2
		let visionStride = Array(stride(from: -visionDimensionOver2, through: visionDimensionOver2, by: 1))
		var locations: [BoardLocation] = []
		
		for y: Int in visionStride {
			for x in visionStride {
				let toLocation = piece.location + BoardLocation(x: x, y: y)
				if piece.movement.canPieceMove(from: piece.location, to: toLocation, board: self),
				   abs(piece.location.x - toLocation.x) <= visionDimension && abs(piece.location.y - toLocation.y) <= visionDimension {
					locations.append(toLocation)
				}
			}
		}
		return locations
	}
}

extension PawnMoveModelInput {
	static func create(inputs: [Double]) -> PawnMoveModelInput {
		return PawnMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], inputs_8: inputs[8], inputs_9: inputs[9], inputs_10: inputs[10], inputs_11: inputs[11], inputs_12: inputs[12], inputs_13: inputs[13], inputs_14: inputs[14], inputs_15: inputs[15], inputs_16: inputs[16], inputs_17: inputs[17], inputs_18: inputs[18], inputs_19: inputs[19], inputs_20: inputs[20], inputs_21: inputs[21], inputs_22: inputs[22], inputs_23: inputs[23], picker: inputs[24])
	}
}

extension RookMoveModelInput {
	static func create(inputs: [Double]) -> RookMoveModelInput {
		return RookMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], inputs_8: inputs[8], inputs_9: inputs[9], inputs_10: inputs[10], inputs_11: inputs[11], inputs_12: inputs[12], inputs_13: inputs[13], inputs_14: inputs[14], inputs_15: inputs[15], inputs_16: inputs[16], inputs_17: inputs[17], inputs_18: inputs[18], inputs_19: inputs[19], inputs_20: inputs[20], inputs_21: inputs[21], inputs_22: inputs[22], inputs_23: inputs[23], inputs_24: inputs[24], inputs_25: inputs[25], inputs_26: inputs[26], inputs_27: inputs[27], inputs_28: inputs[28], inputs_29: inputs[29], inputs_30: inputs[30], inputs_31: inputs[31], inputs_32: inputs[32], inputs_33: inputs[33], inputs_34: inputs[34], inputs_35: inputs[35], inputs_36: inputs[36], inputs_37: inputs[37], inputs_38: inputs[38], inputs_39: inputs[39], inputs_40: inputs[40], inputs_41: inputs[41], inputs_42: inputs[42], inputs_43: inputs[43], inputs_44: inputs[44], inputs_45: inputs[45], inputs_46: inputs[46], inputs_47: inputs[47], picker: inputs[48])
	}
}

extension KnightMoveModelInput {
	static func create(inputs: [Double]) -> KnightMoveModelInput {
		return KnightMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], inputs_8: inputs[8], inputs_9: inputs[9], inputs_10: inputs[10], inputs_11: inputs[11], inputs_12: inputs[12], inputs_13: inputs[13], inputs_14: inputs[14], inputs_15: inputs[15], inputs_16: inputs[16], inputs_17: inputs[17], inputs_18: inputs[18], inputs_19: inputs[19], inputs_20: inputs[20], inputs_21: inputs[21], inputs_22: inputs[22], inputs_23: inputs[23], picker: inputs[24])
	}
}

extension BishopMoveModelInput {
	static func create(inputs: [Double]) -> BishopMoveModelInput {
		return BishopMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], inputs_8: inputs[8], inputs_9: inputs[9], inputs_10: inputs[10], inputs_11: inputs[11], inputs_12: inputs[12], inputs_13: inputs[13], inputs_14: inputs[14], inputs_15: inputs[15], inputs_16: inputs[16], inputs_17: inputs[17], inputs_18: inputs[18], inputs_19: inputs[19], inputs_20: inputs[20], inputs_21: inputs[21], inputs_22: inputs[22], inputs_23: inputs[23], inputs_24: inputs[24], inputs_25: inputs[25], inputs_26: inputs[26], inputs_27: inputs[27], inputs_28: inputs[28], inputs_29: inputs[29], inputs_30: inputs[30], inputs_31: inputs[31], inputs_32: inputs[32], inputs_33: inputs[33], inputs_34: inputs[34], inputs_35: inputs[35], inputs_36: inputs[36], inputs_37: inputs[37], inputs_38: inputs[38], inputs_39: inputs[39], inputs_40: inputs[40], inputs_41: inputs[41], inputs_42: inputs[42], inputs_43: inputs[43], inputs_44: inputs[44], inputs_45: inputs[45], inputs_46: inputs[46], inputs_47: inputs[47], picker: inputs[48])
	}
}

extension QueenMoveModelInput {
	static func create(inputs: [Double]) -> QueenMoveModelInput {
		return QueenMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], inputs_8: inputs[8], inputs_9: inputs[9], inputs_10: inputs[10], inputs_11: inputs[11], inputs_12: inputs[12], inputs_13: inputs[13], inputs_14: inputs[14], inputs_15: inputs[15], inputs_16: inputs[16], inputs_17: inputs[17], inputs_18: inputs[18], inputs_19: inputs[19], inputs_20: inputs[20], inputs_21: inputs[21], inputs_22: inputs[22], inputs_23: inputs[23], inputs_24: inputs[24], inputs_25: inputs[25], inputs_26: inputs[26], inputs_27: inputs[27], inputs_28: inputs[28], inputs_29: inputs[29], inputs_30: inputs[30], inputs_31: inputs[31], inputs_32: inputs[32], inputs_33: inputs[33], inputs_34: inputs[34], inputs_35: inputs[35], inputs_36: inputs[36], inputs_37: inputs[37], inputs_38: inputs[38], inputs_39: inputs[39], inputs_40: inputs[40], inputs_41: inputs[41], inputs_42: inputs[42], inputs_43: inputs[43], inputs_44: inputs[44], inputs_45: inputs[45], inputs_46: inputs[46], inputs_47: inputs[47], picker: inputs[48])
	}
}
	
extension KingMoveModelInput {
	static func create(inputs: [Double]) -> KingMoveModelInput {
		return KingMoveModelInput(inputs_0: inputs[0], inputs_1: inputs[1], inputs_2: inputs[2], inputs_3: inputs[3], inputs_4: inputs[4], inputs_5: inputs[5], inputs_6: inputs[6], inputs_7: inputs[7], picker: inputs[8])
	}
}
