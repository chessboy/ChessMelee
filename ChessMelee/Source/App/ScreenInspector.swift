//
//  ScreenInspector.swift
//  ChessMelee
//
//  Created by Rob Silverman on 1/6/21.
//  Copyright © 2021 Robert Silverman. All rights reserved.
//

import Foundation
import AppKit

class ScreenInspector {
	static let shared = ScreenInspector()
	
	var width: CGFloat = 480
	var height: CGFloat = 300

	init() {
		
		if let screen = NSScreen.main {
			width = screen.frame.size.width
			height = screen.frame.size.height
		}
	}
}
