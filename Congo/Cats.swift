//
//  Cats.swift
//  Congo
//
//  Created by FareedQ on 2016-12-02.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import SpriteKit

struct Cat {
    
    let movePointsPerSec: CGFloat = 480.0
    
    static func spawn(inside: CGRect) -> SKSpriteNode {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: inside.minX,
                              max: inside.maxX),
            y: CGFloat.random(min: inside.minY,
                              max: inside.maxY))
        cat.setScale(0)
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
        return cat
    }
}
