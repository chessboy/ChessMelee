//
//  PlayScene.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018-02-10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6B: The "gameplay" scene for the QuickStart project.
//
//  This scene shows the content for multiple game states: PlayState, PausedState and GameOverState.
//
//  The UI is handled by the PlayUI view designed with SwiftUI.

import SpriteKit
import GameplayKit
import OctopusKit

final class ChessScene: OKScene {
    
    // MARK: - Life Cycle
    
	override func sceneDidLoad() {
		
		// Set the name of this scene at the earliest override-able point, for logging purposes.
		self.name = "ChessScene"
		super.sceneDidLoad()
	}
	
	override func didMove(to: SKView) {
		super.didMove(to: to)
		
		// from ShinryakuTako: Steal the focus on macOS so the player doesn't have to click on the view before using the keyboard.
		to.window?.makeFirstResponder(self)
		// CHECK: why is no cursor stuff working?
		//to.window?.enableCursorRects()
		//to.addCursorRect(to.bounds, cursor: .pointingHand)
		//NSCursor.pointingHand.set()
	}

	// MARK: 🔶 STEP 6B.2
	override func createComponentSystems() -> [GKComponent.Type] {

        // This method is called by the OKScene superclass, after the scene has been presented in a view, to create a list of systems for each component type that must be updated in every frame of this scene.
        //
        // ❗️ The order of components is important, as the functionality of some components depends on the output of other components.
        //
        // See the code and documentation for each component to check its requirements.
        
        [
            // Components that process player input, provided by OctopusKit.
            
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self, // This component translates touch or mouse input into an OS-agnostic "pointer" format, which is used by other input-processing components that work on iOS as well as macOS.
            
            // Custom components which are specific to this QuickStart project.
            
            GlobalDataComponent.self,
            ChessComponent.self
        ]
    }
	
	
    
    // MARK: 🔶 STEP 6B.3
	public override func prepareContents() {

        // This method is called by the OKScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) create its contents and add entities to the scene.
                
        // Create the entities to present in this scene.
		super.prepareContents()

        // Set the permanent visual properties of the scene itself.
        
        self.anchorPoint = CGPoint.half
        
        // Add components to the scene entity.
        
        self.entity?.addComponents([
			sharedMouseOrTouchEventComponent,
			sharedPointerEventComponent,
			GlobalStatsComponent(pointerEventComponent: sharedPointerEventComponent),
		])
                
        // Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
        
        if  let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
            self.addEntity(gameCoordinatorEntity)
        }
    }
    
    // MARK: - State & Scene Transitions
    
    // MARK: 🔶 STEP 6B.4
    override func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
        
        // This method is called by the current game state to notify the current scene when a new state has been entered.
        //
        // Calling super for this method is not necessary; it only adds a log entry.
        
        super.gameCoordinatorDidEnterState(state, from: previousState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: state) {
            
        case is PlayState.Type: // Entering `PlayState`
            
            // self.backgroundColor = SKColor(red: 0.1, green: 0.2, blue: 0.2, alpha: 1)
			self.entity?.addComponent(BrainComponent())
			self.entity?.addComponent(ChessComponent())

			if let view = self.view {
				view.showsFPS = true
				view.showsNodeCount = true
				view.showsDrawCount = true
				view.ignoresSiblingOrder = true
				view.shouldCullNonVisibleNodes = true
				view.preferredFramesPerSecond = 60
			}

        default: break
        }
    }
    
    // MARK: 🔶 STEP 6B.5
    override func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
        
        // This method is called by the current game state to notify the current scene when the state will transition to a new state.
        
        super.gameCoordinatorWillExitState(exitingState, to: nextState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: exitingState) {
        
        case is PlayState.Type: // Exiting `PlayState`
            self.entity?.removeComponent(ofType: ChessComponent.self)
                        
        default: break
        }
    }
	
	override func mouseDown(with event: NSEvent) {
		let commandDown = event.modifierFlags.contains(.command)
		let shiftDown = event.modifierFlags.contains(.shift)
		let optionDown = event.modifierFlags.contains(.option)
		self.touchDown(with: event, commandDown: commandDown, shiftDown: shiftDown, optionDown: optionDown, clickCount: event.clickCount)
	}

	override func rightMouseDown(with event: NSEvent) {
		let commandDown = event.modifierFlags.contains(.command)
		let shiftDown = event.modifierFlags.contains(.shift)
		let optionDown = event.modifierFlags.contains(.option)
		self.touchDown(with: event, rightMouse: true, commandDown: commandDown, shiftDown: shiftDown, optionDown: optionDown)
	}

	func touchDown(with event: NSEvent, rightMouse: Bool = false, commandDown: Bool = false, shiftDown: Bool = false, optionDown: Bool = false, clickCount: Int = 1) {
				
		guard let chessComponent = entity?.component(ofType: ChessComponent.self) else {
			return
		}
		
		let point = event.location(in: self)
		chessComponent.touchDown(point: point, rightMouse: rightMouse, commandDown: commandDown, shiftDown: shiftDown, optionDown: optionDown, clickCount: clickCount)
	}
    
	override func keyDown(with event: NSEvent) {
		
		//let shiftDown = event.modifierFlags.contains(.shift)
		let commandDown = event.modifierFlags.contains(.command)
		//let optionDown = event.modifierFlags.contains(.option)

		switch event.keyCode {
			
		case Keycode.space:
			if let chessComponent = self.entity?.component(ofType: ChessComponent.self) {
				chessComponent.togglePause()
			}
			break
			
		case Keycode.r:
			if commandDown, let chessComponent = self.entity?.component(ofType: ChessComponent.self) {
				chessComponent.setupBoard()
			}
			break
			
		case Keycode.s:
			if Constants.Training.guidedTraining, commandDown, let chessComponent = self.entity?.component(ofType: ChessComponent.self) {
				chessComponent.saveTrainingRecords()
			}
			break

		default: break
		}
	}
    // MARK: - Pausing/Unpausing
    
	override func applicationWillResignActive() {
		// override to not pause by system
	}

    override func didPauseBySystem() {
        
        // 🔶 STEP 6B.?: This method is called when the player switches to a different application, or the device receives a phone call etc.
        //
        // Here we enter the PausedState if the game was in the PlayState.
        
//        if  let currentState = OctopusKit.shared?.gameCoordinator.currentState,
//            type(of: currentState) is PlayState.Type
//        {
//            self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
//        }
    }

    override func didPauseByPlayer() {
        self.physicsWorld.speed = 0.0
        self.isPaused = true
    }
    
    override func didUnpauseByPlayer() {
        self.physicsWorld.speed = 1.0
        self.isPaused = false
    }
}

// NEXT: See PlayUI (STEP 6C) and PausedState (STEP 7)

