//
//  GameScene.swift
//  Congo
//
//  Created by FareedQ on 2016-11-29.
//  Copyright © 2016 FareedQ. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "background1")
    let zombie = Zombie(imageNamed: "zombie1")
    
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var playableRect: CGRect
    
    var lastTouchLocation = CGPoint.zero
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        background.zPosition = -1
        zombie.zPosition = 100
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        zombie.position = CGPoint(x: 400, y: 400)
        
        addChild(background)
        addChild(zombie)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
            self?.addChild(Enemy.spawn(inside: (self?.playableRect)!))
            },SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
            self?.addChild(Cat.spawn(inside: (self?.playableRect)!))
            },SKAction.wait(forDuration: 1.0)])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        let offset = lastTouchLocation - zombie.position
        let length = offset.length()
        if(length <= zombie.movePointsPerSec * CGFloat(deltaTime)){
            zombie.position = lastTouchLocation
            zombie.velocity = CGPoint.zero
            zombie.stopZombieAnimation()
        } else {
            move(sprite: zombie, velocity: zombie.velocity)
            rotate(sprite: zombie, direction: zombie.velocity, rotateRadiansPerSec: zombie.rotateRadiansPerSec)
        }
        
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        moveTrain()
        if lives <= 0 && !gameOver {
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: false)
            endGame(gameOverScene: gameOverScene)
        } else if trainCount >= 15 && !gameOver {
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: true)
            endGame(gameOverScene: gameOverScene)
        }
    }
    
    func endGame(gameOverScene: GameOverScene) {
        backgroundMusicPlayer.stop()
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
        lives = 5
        trainCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            node.removeFromParent()
        }
        
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func sceneTouched(touchLocation:CGPoint){
        zombie.moveToward(location:touchLocation)
        lastTouchLocation = touchLocation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func move(sprite: SKSpriteNode, velocity:CGPoint) {
        let amountToMove = velocity * CGFloat(deltaTime)
        sprite.position += amountToMove
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombie.hit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombie.hit(enemy: enemy)
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        enumerateChildNodes(withName: "train") { node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let moveAction = SKAction.move(to: targetPosition, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let newAngle = atan2(direction.y, direction.x)
        let wayToRotate = shortestAngleBetween(angle1: sprite.zRotation, angle2: newAngle)
        let amountToRotate = rotateRadiansPerSec * CGFloat(deltaTime)
        var turn = sprite.zRotation - newAngle * amountToRotate
        if abs(turn) > abs(newAngle) { turn = newAngle }
        sprite.zRotation = newAngle
    }
    
}
