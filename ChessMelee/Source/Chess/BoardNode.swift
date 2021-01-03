//
//  GridNode.swift
//  SwiftBots
//
//  Created by Robert Silverman on 9/5/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import SpriteKit
import OctopusKit

class BoardNode: SKNode {
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init() {
		super.init()
		let numRows = Constants.Chessboard.rowCount
		let numCols = Constants.Chessboard.columnCount
		let squareDim: CGFloat = Constants.Chessboard.squareDimension
		
		let squareSize = CGSize(width: squareDim, height: squareDim)
		let xOffset: CGFloat = -(squareDim * (CGFloat(numCols)-1))/2
		let yOffset: CGFloat = -(squareDim * (CGFloat(numRows)-1))/2
		// Column characters

		var toggle:Bool = true
		var index = 0
		for row in 0...numRows-1 {
			for col in 0...numCols-1 {
				let color = toggle ? Constants.Color.whiteSquareColor : Constants.Color.blackSquareColor
				let square = SKSpriteNode(color: color, size: squareSize)
				square.position = CGPoint(
					x: CGFloat(col) * squareSize.width + xOffset,
					y: CGFloat(row) * squareSize.height + yOffset)
				
				square.name = "\(index)"
				self.addChild(square)
				
//				let lableNode = SKLabelNode(text: "\(index)")
//				lableNode.font.size = 12
//				lableNode.fontColor = .black
//				lableNode.zPosition = 100
//				lableNode.position = CGPoint(x: 0, y: -5)
//				square.addChild(lableNode)
				
				toggle = !toggle
				index += 1
			}
			toggle = !toggle
		}
	}
		
    func squareNodeForLocation(_ location: BoardLocation) -> SKSpriteNode? {
		return self.childNode(withName: String(location.index)) as? SKSpriteNode
    }
	
	func highlightSquare(location: BoardLocation, color: SKColor) {

		if let squareNode = squareNodeForLocation(location) {
			
			let node = SKSpriteNode(color: color, size: squareNode.size)
			node.blendMode = .alpha
			node.position = squareNode.center
			node.alpha = 0
			addChild(node)
			node.run(SKAction.fadeIn(withDuration: 0.25)) {
				node.run(SKAction.fadeOut(withDuration: 0.25)) {
					node.removeFromParent()
				}
			}
		}
	}
	
	func drawLine(loc1: BoardLocation, loc2: BoardLocation, color: SKColor, thickness: CGFloat = 8) {

		if let n1 = squareNodeForLocation(loc1), let n2 = squareNodeForLocation(loc2) {
			let path = CGMutablePath()
			path.move(to: n1.position)
			path.addLine(to: n2.position)

			let node = SKShapeNode()
			node.lineWidth = thickness
			node.lineCap = .round
			node.strokeColor = color
			node.path = path

			node.alpha = 0
			addChild(node)
			node.run(SKAction.fadeIn(withDuration: 0.25)) {
				node.run(SKAction.fadeOut(withDuration: 0.25)) {
					node.removeFromParent()
				}
			}
		}
	}
			
	func removeAllPieces() {
		let toBeRemoved = children.filter({ ($0.name?.starts(with: "piece") ?? false)})
		removeChildren(in: toBeRemoved)
	}
	
	func addPiece(_ piece: Piece, at boardLoc: BoardLocation) {
		
		let id = piece.color == .white ? "w" : "b"
		let imageName = "\(id)\(piece.type.char)"
		//let locationName = boardLoc.gridPosition.name
		//print("addPiece: \(locationName): \(imageName)")
		
		let node = SKSpriteNode(imageNamed: imageName).scale(0.7 * 0.375)
		node.zPosition = 1
		node.name = "piece_\(imageName)_\(String(boardLoc.index))"
		if let squareNode = squareNodeForLocation(boardLoc) {
			node.position = squareNode.center
		}
		
		self.addChild(node)
	}

	func movePiece(_ piece: Piece, from: BoardLocation, to: BoardLocation) {
		let id = piece.color == .white ? "w" : "b"
		let imageName = "\(id)\(piece.type.char)"
		let fromName = "piece_\(imageName)_\(String(from.index))"
		
		if let fromNode = childNode(withName: fromName), let toPosition = squareNodeForLocation(to)?.center {
			let toName = "piece_\(imageName)_\(String(to.index))"
			fromNode.name = toName
			fromNode.run(SKAction.move(to: toPosition, duration: 0.25).withTimingMode(.easeOut))
			drawLine(loc1: from, loc2: to, color: Constants.Color.moveLineColor, thickness: 8)
		}
	}
	
	func removePiece(_ piece: Piece, from: BoardLocation) {
		let id = piece.color == .white ? "w" : "b"
		let imageName = "\(id)\(piece.type.char)"
		let fromName = "piece_\(imageName)_\(String(from.index))"
		
		if let fromNode = childNode(withName: fromName) {
			let fadeAndRemove = SKAction.fadeOutAndRemove(withDuration: 0.25, timingMode: .linear)
			fromNode.run(fadeAndRemove)
		}
	}

}
