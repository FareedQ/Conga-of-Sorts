//
//  MainMenuScene.swift
//  Congo
//
//  Created by FareedQ on 2016-12-10.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import Foundation
import SpriteKit
class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
        background = SKSpriteNode(imageNamed: "YouWin")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(block)
    }
    
}
