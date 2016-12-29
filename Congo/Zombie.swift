//
//  zombie.swift
//  Congo
//
//  Created by FareedQ on 2016-12-02.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import SpriteKit

var lives = 5
var trainCount = 0
var gameOver = false

class Zombie : SKSpriteNode {
    
    var velocity = CGPoint.zero
    let zombieAnimation: SKAction
    let movePointsPerSec: CGFloat = 480.0
    let rotateRadiansPerSec = 4.0 * π
    
    var isInvincible = false
    let blinkTimes = 10.0
    let duration = 3.0

    let blinkAction: SKAction
    
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    
    init(imageNamed: String){
        guard let image = UIImage(named: imageNamed) else {
            zombieAnimation = SKAction()
            blinkAction = SKAction()
            super.init(texture: SKTexture(), color: UIColor.black, size: CGSize())
            return
        }
        
        let texture = SKTexture(image: image)
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        let duration = self.duration
        let blinkTimes = self.blinkTimes
        blinkAction = SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        
        super.init(texture: texture, color: UIColor.black, size: image.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTexture() -> [SKTexture] {
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        return textures
    }
    
    func boundsCheckZombie(insideArea: CGRect){
        let bottomLeft = CGPoint(x: 0, y: insideArea.minY)
        let topRight = CGPoint(x: insideArea.width, y: insideArea.maxY)
        
        if self.position.x <= bottomLeft.x {
            self.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if self.position.x >= topRight.x {
            self.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if self.position.y <= bottomLeft.y {
            self.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if self.position.y >= topRight.y {
            self.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func startZombieAnimation() {
        if self.action(forKey: "animation") == nil {
            self.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        self.removeAction(forKey: "animation")
    }
    
    func moveToward(location:CGPoint) {
        self.startZombieAnimation()
        let offset = location - self.position
        let length = offset.length()
        let direction = offset/length
        self.velocity = direction * self.movePointsPerSec
    }
    
    func hit(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        cat.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: 1, duration: 0.5))
        run(catCollisionSound)
        trainCount += 1
    }
    
    func hit(enemy: SKSpriteNode) {
        
        let invincible = SKAction.run({
            self.isInvincible = false
        })
        
        if !isInvincible {
            isInvincible = true
            run(enemyCollisionSound)
            if self.action(forKey: "invincible") == nil {
                self.run(
                    SKAction.sequence([blinkAction, invincible]),
                    withKey: "invincible")
            }
            lives -= 1
            loseCats()
        }
    }
    
    func loseCats() {
        var loseCount = 0
        parent?.enumerateChildNodes(withName: "train") { node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            loseCount += 1
            trainCount -= 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
}
