//
//  Piece.swift
//  Pods
//
//  Created by Steve Barnegren on 04/09/2016.
//
//

// swiftlint:disable file_length
// swiftlint:disable type_body_length

import Foundation

public enum CastleSide {
    case kingSide
    case queenSide
}

// MARK: - ****** Square ******

public struct Square: Equatable {
    
    public var piece: Piece?

}

public func == (lhs: Square, rhs: Square) -> Bool {
    
    switch (lhs.piece, rhs.piece) {
    case (.none, .none):
        return true
    case (.some(let rp), .some(let lp)):
        return rp.isSameTypeAndColor(asPiece: lp)
    default:
        return false
    }
}

// MARK: - ****** Board ******

public struct Board: Equatable {
        
    public private(set) var squares = [Square]()
    
    // MARK: - Init
    public init() {
        
        // Setup squares
		for _ in 0..<Constants.Chessboard.squareCount {
            squares.append(Square())
        }
    }
    
    // MARK: - Manipulate Pieces
    
    public mutating func setPiece(_ piece: Piece, at location: BoardLocation) {
        squares[location.index].piece = piece
        squares[location.index].piece?.location = location
    }
    
    public func getPiece(at location: BoardLocation) -> Piece? {
        return squares[location.index].piece
    }
    
    public mutating func removePiece(at location: BoardLocation) {
        squares[location.index].piece = nil
    }
    
	@discardableResult internal mutating func movePiece(from fromLocation: BoardLocation,
														to toLocation: BoardLocation) -> [BoardOperation] {
		
		if toLocation == fromLocation {
			return []
		}
	
		var operations = [BoardOperation]()
		
		guard let movingPiece = getPiece(at: fromLocation) else {
			fatalError("There is no piece on at (\(fromLocation.x),\(fromLocation.y))")
		}
		
		let operation = BoardOperation(type: .movePiece, piece: movingPiece, location: toLocation)
		operations.append(operation)

		if let targetPiece = getPiece(at: toLocation) {
			let operation = BoardOperation(type: .removePiece, piece: targetPiece, location: toLocation)
			operations.append(operation)
		}
		
		squares[toLocation.index].piece = self.squares[fromLocation.index].piece
		squares[toLocation.index].piece?.location = toLocation
		squares[toLocation.index].piece?.hasMoved = true
		squares[fromLocation.index].piece = nil
				
		return operations
	}
	
    // MARK: - Get Specific pieces
        
    public func getLocations(of color: PlayerColor) -> [BoardLocation] {
        
        var locations = [BoardLocation]()
        
        for (index, square) in squares.enumerated() {
            
            guard let piece = square.piece else {
                continue
            }
            
            if piece.color == color {
                locations.append(BoardLocation(index: index))
            }
        }
        
        return locations
    }
    
    public func getPieces(color: PlayerColor) -> [Piece] {
        
        var pieces = [Piece]()
        
        for square in squares {
            
            guard let piece = square.piece else {
                continue
            }
            
            if piece.color == color {
                pieces.append(piece)
            }
        }
        
        return pieces
        
    }
    		
    // MARK: - Possession
    
    func canColorMoveAnyPieceToLocation(color: PlayerColor, location: BoardLocation) -> Bool {
        
        for (index, square) in squares.enumerated() {
            
            guard let piece = square.piece else {
                continue
            }

            if piece.color != color {
                continue
            }
            
            if piece.movement.canPieceMove(from: BoardLocation(index: index), to: location, board: self) {
                return true
            }
        }
 
        return false
    }
    
    func doesColorOccupyLocation(color: PlayerColor, location: BoardLocation) -> Bool {
        
        guard let piece = getPiece(at: location) else {
            return false
        }

        return (piece.color == color ? true : false)
    }
    
    public func possibleMoveLocationsForPiece(atLocation location: BoardLocation) -> [BoardLocation] {
        
        guard let piece = squares[location.index].piece else {
            return []
        }
        
        var locations = [BoardLocation]()
        
        BoardLocation.all.forEach {
            if piece.movement.canPieceMove(from: location, to: $0, board: self) {
                locations.append($0)
            }
        }
        
        return locations
    }
}

public func == (lhs: Board, rhs: Board) -> Bool {
    return lhs.squares == rhs.squares
}
