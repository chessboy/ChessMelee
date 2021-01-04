//
//  Piece.swift
//  Pods
//
//  Created by Steve Barnegren on 04/09/2016.
//
//

import Foundation

public enum PlayerColor: String, CaseIterable {
    case white = "White"
    case black = "Black"
    
    public var opposite: PlayerColor {
        return (self == .white) ? .black : .white
    }
    
    public var string: String {
        return rawValue.lowercased()
    }
    
    public var stringWithCapital: String {
        return rawValue
    }
}

public enum PieceType: Int, CaseIterable, CustomStringConvertible, Codable {
	case pawn
	case rook
	case knight
	case bishop
	case queen
	case king
	
	var visionDimension: Int {
		switch self {
		case .pawn: return 5
		case .rook: return 7 		// --> 11 max
		case .knight: return 5
		case .bishop: return 7		// --> 11 max
		case .queen: return 7		// --> 11 max
		case .king: return 3
		}
	}
	
	var value: Double {
		switch self {
		case .pawn: return 1
		case .rook: return 5
		case .knight: return 3
		case .bishop: return 3
		case .queen: return 9
		case .king: return 50
		}
	}
	
	var char: Character {
		switch self {
		case .pawn: return "p"
		case .rook: return "r"
		case .knight: return "n"
		case .bishop: return "b"
		case .queen: return "q"
		case .king: return "k"
		}
	}
	
	public var description: String {
		switch self {
		case .pawn: return "pawn"
		case .rook: return "rook"
		case .knight: return "knight"
		case .bishop: return "bishop"
		case .queen: return "queen"
		case .king: return "king"
		}
	}
	
	static func fromKeycode(keycode: UInt16) -> PieceType {
		switch keycode {
		case Keycode.two: return .rook
		case Keycode.three: return .knight
		case Keycode.four: return .bishop
		case Keycode.five: return .queen
		case Keycode.six: return .king
		default: return .pawn // Keycode.one
		}
	}
			
	static func possiblePawnPromotionResultingTypes() -> [PieceType] {
		return [.queen, .knight, .rook, .bishop]
	}
}

public struct Piece: Equatable, CustomStringConvertible {
	
    public let type: PieceType
    public let color: PlayerColor
    public internal(set) var tag: Int!
    public internal(set) var hasMoved = false
    public internal(set) var location = BoardLocation(index: 0)
	public internal(set) var zoneId: Int = 0
	
	public var description: String {
		return "{\(color) \(type)}"
	}
	
    var movement: PieceMovement! {
        return PieceMovement.pieceMovement(for: self.type)
    }
        
    var value: Double {
        return type.value
    }
    
	public init(type: PieceType, color: PlayerColor, tag: Int, zoneId: Int) {
        self.type = type
        self.color = color
		self.tag = tag
		self.zoneId = zoneId
    }
        
    func isSameTypeAndColor(asPiece other: Piece) -> Bool {
        
        if self.type == other.type && self.color == other.color {
            return true
        } else {
            return false
        }
    }
	
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

public func == (left: Piece, right: Piece) -> Bool {
	
	if left.type == right.type
		&& left.color == right.color
		&& left.tag == right.tag
		&& left.zoneId == right.zoneId
		&& left.hasMoved == right.hasMoved
		&& left.location == right.location {
		return true
	} else {
		return false
	}
}
