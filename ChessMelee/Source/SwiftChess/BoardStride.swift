//
//  BoardStride.swift
//  SwiftChess
//
//  Created by Steve Barnegren on 30/01/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import Foundation

public struct BoardStride: CustomStringConvertible {
    
    public var x: Int
    public var y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
	
	public var description: String {
		return "{x: \(x), y: \(y)}"
	}
}
