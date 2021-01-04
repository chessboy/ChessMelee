//
//  ChessMeleeTests.swift
//  ChessMeleeTests
//
//  Created by Rob Silverman on 12/29/20.
//  Copyright © 2020 Robert Silverman. All rights reserved.
//

import XCTest
@testable import ChessMelee

class ChessMeleeTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testInputs() throws {
		print()
		let board = createBoard()
		let piece1 = board.getPiece(at: BoardLocation(index: 0))
		let piece2 = board.getPiece(at: BoardLocation(index: 767))
		let inputs1 = BrainComponent.createInputsForBoard(board, at: piece1!.location)
		let inputs2 = BrainComponent.createInputsForBoard(board, at: piece2!.location)

		print(inputs1.map({Int($0)}))
		print(inputs2.map({Int($0)}))

		let piece1InputCount = (piece1!.type.visionDimension * piece1!.type.visionDimension) - 1
		let piece2InputCount = (piece2!.type.visionDimension * piece1!.type.visionDimension) - 1

		XCTAssert(inputs1.count == piece1InputCount)
		XCTAssert(inputs2.count == piece2InputCount)
		XCTAssert(inputs1 == inputs2)
	}

	/**
		 00 01 02 03 04
		 --------------
	00 | 00 01 02 03 04  -->  -2,+2  -1,+2  00,+2  +1,+2  +2,+2
	01 | 05 06 07 08 09  -->  -2,+1  -1,+1  00,+1  +1,+1  +2,+1
	02 | 10 11 -- 12 13  -->  -2,00  -1,00  --,--  +1,00  +2,00
	03 | 14 15 16 17 18  -->  -2,-1  -1,-1  00,-1  +1,-1  +2,-1
	04 | 19 20 21 22 23  -->  -2,-2  -1,-2  00,-2  +1,-2  +2,-2
	*/
	func testIndexing() throws {
		
		let visionDimension = 5
		let visionDimensionOver2 = visionDimension/2
		let centerIndex = (visionDimension * visionDimension) / 2
		print("visionDimension: \(visionDimension), visionDimensionOver2: \(visionDimensionOver2), centerIndex: \(centerIndex)")

		for index in 0..<visionDimension * visionDimension - 1 {

			let adjustForCenter = index < centerIndex ? 0 : 1
			let x = ((index+adjustForCenter) % visionDimension) - visionDimensionOver2
			let y = visionDimensionOver2 - ((index+adjustForCenter) / visionDimension)
			print("white: \(index), x: \(x), y: \(y)")
		}
	}
	
	func testCsvFileSave() throws {
		LocalFileManager.shared.saveTrainingRecordsToCsvFile([TrainingRecord](), for: .pawn)
	}
	
	/**
		 00 01 02 03 04
		 --------------
	00 | 00 01 02 03 04  -->  -2,+2  -1,+2  00,+2  +1,+2  +2,+2
	01 | 05 06 07 08 09  -->  -2,+1  -1,+1  00,+1  +1,+1  +2,+1
	02 | 10 11 -- 12 13  -->  -2,00  -1,00  --,--  +1,00  +2,00
	03 | 14 15 16 17 18  -->  -2,-1  -1,-1  00,-1  +1,-1  +2,-1
	04 | 19 20 21 22 23  -->  -2,-2  -1,-2  00,-2  +1,-2  +2,-2
	*/
	func testReverseIndexing() throws {
		
		let visionDimension = 5
		let visionDimensionOver2 = visionDimension/2
		let centerIndex = (visionDimension * visionDimension) / 2
		
		XCTAssert(visionDimension % 2 == 1)
		
		print("visionDimension: \(visionDimension), visionDimensionOver2: \(visionDimensionOver2), centerIndex: \(centerIndex)")
		
		let visionStride = Array(stride(from: -visionDimensionOver2, through: visionDimensionOver2, by: 1))
		let xStride = visionStride						// [-3, -2, -1, 0, 1, 2, 3]
		let yStride = visionStride.reversed()			// [3, 2, 1, 0, -1, -2, -3]

		var counter = 0
		for y: Int in yStride {									// [3, 2, 1, 0, -1, -2, -3]
			for x in xStride {									// [-3, -2, -1, 0, 1, 2, 3]
				if !(x == 0 && y == 0) {
					let rank = -y + visionDimensionOver2		// [6, 5, 4, 3, 4, 5, 6]
					let file = x + visionDimensionOver2 		// [0, 1, 2, 3, 4, 5, 6]
					var index = rank*visionDimension + file
					if index >= centerIndex {
						index -= 1
					}
					print("[\(counter)] y: \(y), x: \(x), rank: \(rank), file: \(file) --> index: \(index)")
					counter += 1
				}
			}
		}
		
		XCTAssert(counter == visionDimension * visionDimension - 1)
	}

	func createBoard() -> Board {
		
		var tagGenerator = 0
		var board = Board()
		
		let pieces: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
		
		func makePiece(index: Int, type: PieceType, color: PlayerColor) -> Piece {
			let zoneId = (index % Constants.Chessboard.columnCount)/(Constants.Chessboard.zoneCount/2) * 2 + (color == .white ? 0 : 1)
			tagGenerator += 1
			return Piece(type: type, color: color, tag: tagGenerator, zoneId: zoneId)
		}

		// white bottom row
		for i in 0...63 {
			board.setPiece(makePiece(index: i, type: pieces[i%8], color: .white), at: BoardLocation(index: i))
		}

		// white pawn row
		for i in 64...127 {
			board.setPiece(makePiece(index: i, type: .pawn, color: .white), at: BoardLocation(index: i))
		}
		
		// black bottom row
		for i in 704...767 {
			board.setPiece(makePiece(index: i, type: pieces[i%8], color: .black), at: BoardLocation(index: i))
		}

		// black pawn row
		for i in 640...703 {
			board.setPiece(makePiece(index: i, type: .pawn, color: .black), at: BoardLocation(index: i))
		}

		return board
	}
}
