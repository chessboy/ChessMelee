//
//  GlobalStatsComponent.swift
//  ChessMelee
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class GlobalStatsComponent: OKComponent, OKUpdatableComponent {
	
	var textNode: SKLabelNode!
	var maskNode: SKSpriteNode!
	var pointerEventComponent: PointerEventComponent
	
	init(pointerEventComponent: PointerEventComponent) {
		self.pointerEventComponent = pointerEventComponent
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateStats(_ text: String) {
		textNode.text = text
	}
	
	func updateStats(_ text: NSAttributedString) {
		textNode.attributedText = text
	}

	func setPaused(_ paused: Bool) {
		let color = paused ? SKColor(red: 0.5, green: 0, blue: 0, alpha: 0.5) : .clear
		let colorize = SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.15)
		maskNode.run(colorize)
	}
	
	func toggleVisibility() {
		let isHidden = maskNode.isHidden
		
		if isHidden {
			maskNode.isHidden = false
			maskNode.alpha = 0
			maskNode.run(.fadeIn(withDuration: 0.15))
		} else {
			maskNode.run(.fadeOut(withDuration: 0.25)) {
			   self.maskNode.isHidden = true
			}
		}
	}
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self
	]}
	
	override func didAddToEntity(withNode node: SKNode) {
		
		let height: CGFloat = Constants.Interaction.statsHeight

		let parentFrame = node.frame
		let rect = CGRect(x: parentFrame.minX, y: 0, width: parentFrame.width, height: height)
		maskNode = SKSpriteNode(color: .clear, size: rect.size)
		maskNode.position = CGPoint(x: 0, y: parentFrame.origin.y + height/2)
		maskNode.zPosition = 200

    	textNode = SKLabelNode()
		textNode.numberOfLines = 2
		textNode.horizontalAlignmentMode = .center
		textNode.verticalAlignmentMode = .center
		maskNode.addChild(textNode)
		
		node.addChild(maskNode)
		
		setSimpleText(text: "🚀 Starting up...")
	}
	
	func setSimpleText(text: String) {
		let builder = AttributedStringBuilder()
		builder.defaultAttributes = [.font(UIFont.systemFont(ofSize: 22)), .textColor(UIColor.white), .alignment(.center)]
		builder.text(text)
		textNode.attributedText = builder.attributedString
	}
}
