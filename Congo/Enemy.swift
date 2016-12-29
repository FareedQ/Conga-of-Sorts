//
//  enemy.swift
//  Congo
//
//  Created by FareedQ on 2016-12-02.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import SpriteKit

struct Enemy {
    
    static func spawn(inside: CGRect) -> SKSpriteNode {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: inside.width + enemy.size.width/2,
            y: CGFloat.random(
                min: inside.minY + enemy.size.height/2,
                max: inside.maxY - enemy.size.height/2))
        let actionMove =
            SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
        return enemy
    }
}
