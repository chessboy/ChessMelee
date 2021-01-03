//
//  BoardLocation.swift
//  SwiftChess
//
//  Created by Steve Barnegren on 30/01/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import Foundation

public struct BoardLocation: Equatable {
        
    public var index: Int
	    
    private static var allLocationsBacking: [BoardLocation]?
    public static var all: [BoardLocation] {
        
        if let all = allLocationsBacking {
            return all
        } else {
            var locations = [BoardLocation]()
            
			(0..<Constants.Chessboard.squareCount).forEach {
                locations.append(BoardLocation(index: $0))
            }
            
            allLocationsBacking = locations
            return allLocationsBacking!
        }
    }
    
    public var isDarkSquare: Bool {
        return (index + y) % 2 == 0
    }
    
    public var x: Int {
        return index % Constants.Chessboard.columnCount
    }
    
    public var y: Int {
        return index / Constants.Chessboard.columnCount
    }
    
    public init(index: Int) {
        self.index = index
    }
    
    public init(x: Int, y: Int) {
        self.index = x + (y*Constants.Chessboard.columnCount)
    }
    
    func isInBounds() -> Bool {
        return (index < Constants.Chessboard.squareCount && index >= 0)
    }
    
    func incremented(by offset: Int) -> BoardLocation {
        return BoardLocation(index: index + offset)
    }
    
    func incrementedBy(x: Int, y: Int) -> BoardLocation {
        return self + BoardLocation(x: x, y: y)
    }
    
    func incremented(by stride: BoardStride) -> BoardLocation {
        
        // swiftlint:disable line_length
        assert(canIncrement(by: stride),
               "BoardLocation is being incremented by a stride that will result in wrapping! call canIncrementBy(stride: BoardStride) first")
        // swiftlint:enable line_length
        
        return BoardLocation(x: x + stride.x,
                             y: y + stride.y)
    }
    
    func canIncrement(by stride: BoardStride) -> Bool {
        
        // Check will not wrap to right
        if x + stride.x > Constants.Chessboard.columnCount - 1 {
            return false
        }
        
        // Check will not wrap to left
        if x + stride.x < 0 {
            return false
        }
        
        // Check will not wrap top
        if y + stride.y > Constants.Chessboard.rowCount - 1 {
            return false
        }
        
        // Check will not wrap bottom
        if y + stride.y < 0 {
            return false
        }
        
        return true
    }
    
    func strideTo(location: BoardLocation) -> BoardStride {
        
        return BoardStride(x: location.x - x,
                           y: location.y - y)
    }
    
    func strideFrom(location: BoardLocation) -> BoardStride {
        
        return BoardStride(x: x - location.x,
                           y: y - location.y)
    }
}

public func == (lhs: BoardLocation, rhs: BoardLocation) -> Bool {
    return lhs.index == rhs.index
}

public func + (left: BoardLocation, right: BoardLocation) -> BoardLocation {
    return BoardLocation(index: left.index + right.index)
}
