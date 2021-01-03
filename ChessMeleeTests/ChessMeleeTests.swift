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
		let inputs1 = board.createInputs(at: BoardLocation(index: 0), debug: true)
		let inputs2 = board.createInputs(at: BoardLocation(index: 767), debug: true)
		
		print(inputs1.map({Int($0)}))
		print(inputs2.map({Int($0)}))
		
		XCTAssert(inputs1.count == Constants.NeuralNetwork.inputCount)
		XCTAssert(inputs2.count == Constants.NeuralNetwork.inputCount)
		XCTAssert(inputs1 == inputs2)
	}
	
	func testTiming() throws {
		
		// gen 0: 200 --> gen 100: 3200
				
		for gen: Float in stride(from: 0, through: 120, by: 1) {
			let trajectory = log10(min(gen, 100) + 3)
			let ticks = Int(trajectory * trajectory * 1000)
			print("gen: \(gen), log(gen): \(ticks)")
		}
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
		
		let visionDimension = Constants.Vision.dimension
		let visionDimensionOver2 = Constants.Vision.dimension / 2
		let centerIndex = (visionDimension * visionDimension) / 2

		for index in 0...23 {

			var x = -1
			var y = -1
			let adjustForCenter = index < centerIndex ? 0 : 1
			x = ((index+adjustForCenter) % visionDimension) - visionDimensionOver2
			y = visionDimensionOver2 - ((index+adjustForCenter) / visionDimension)

			print("white: \(index), x: \(x), y: \(y) - black: \(index), x: \(-x), y: \(-y)")
		}
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
		
		let visionDimension = Constants.Vision.dimension
		let centerIndex = (visionDimension * visionDimension) / 2

		let xStride = [-2, -1, 0, 1, 2]
		let yStride = [-2, -1, 0, 1, 2].reversed()

		for y: Int in yStride {
			for x in xStride {
				if !(x == 0 && y == 0) {
					var index = -(y-2)*visionDimension + (x + 2)
					if index >= centerIndex {
						index -= 1
					}
					print("x: \(x), y: \(y), index:\(index)")
				}
			}
		}
	}

	func createBoard() -> Board {
		
		var board = Board()
		
		let pieces: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
		
		func makePiece(type: PieceType, color: PlayerColor) -> Piece {
			return Piece(type: type, color: color)
		}

		// white bottom row
		for i in 0...63 {
			board.setPiece(makePiece(type: pieces[i%8], color: .white), at: BoardLocation(index: i))
		}

		// white pawn row
		for i in 64...127 {
			board.setPiece(makePiece(type: .pawn, color: .white), at: BoardLocation(index: i))
		}
		
		// black bottom row
		for i in 704...767 {
			board.setPiece(makePiece(type: pieces[i%8], color: .black), at: BoardLocation(index: i))
		}

		// black pawn row
		for i in 640...703 {
			board.setPiece(makePiece(type: .pawn, color: .black), at: BoardLocation(index: i))
		}

		return board
	}
}
