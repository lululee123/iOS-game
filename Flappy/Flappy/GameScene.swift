//
//  GameScene.swift
//  Flappy
//
//  Created by 李文慈 on 2017/5/22.
//  Copyright © 2017年 lulu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var leftCar = SKSpriteNode()
    var rightCar = SKSpriteNode()
    
    var canMove = true
    var leftCarToMoveleft = true
    var rightCarToMoveright = true
    var leftCarAtright = false
    var rightCarAtleft = false
    var CenterPoint: CGFloat!
    
    let leftCarminimumX: CGFloat = -280
    let leftCarmaximumX:CGFloat = -100
    let rightCarminimumX: CGFloat = 100
    let rightCarmaximumX:CGFloat = 280
    
    var stopEverything = false
    var score = 0
    var scoreText = SKLabelNode()
    var gameSetting = Setting.sharedInstance
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint (x: 0.5, y: 0.5)
        setup()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createline), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftItems), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightItems), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.remove), userInfo: nil, repeats: true)
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime)
        {
            Timer.scheduledTimer(timeInterval:  TimeInterval(1),target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if canMove
        {
            moveleftCar(leftSide: leftCarToMoveleft)
            moverightCar(rightSide: rightCarToMoveright)
        }
        showline()
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar"
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if touchLocation.x > CenterPoint
            {
                if rightCarAtleft
                {
                    rightCarAtleft = false
                    rightCarToMoveright = true
                }
                else
                {
                    rightCarAtleft = true
                    rightCarToMoveright = false
                }
            }
            else
            {
                if leftCarAtright
                {
                    leftCarAtright = false
                    leftCarToMoveleft = true
                }
                else
                {
                    leftCarAtright = true
                    leftCarToMoveleft = false
                }

            }
        }
    }
    func setup()
    {
        leftCar = self.childNode(withName: "leftCar") as! SKSpriteNode
        rightCar = self.childNode(withName: "rightCar") as! SKSpriteNode
        CenterPoint = self.frame.size.width / self.frame.size.height
        
        leftCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        leftCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        leftCar.physicsBody?.collisionBitMask = 0
        
        rightCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rightCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        rightCar.physicsBody?.collisionBitMask = 0
        
        let scoreBackGround = SKShapeNode(rect: CGRect(x: -self.size.width/2 + 70, y: self.size.height/2 - 130, width: 180, height: 80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y:self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    //中間的線
    func createline()
    {
        let leftline = SKShapeNode(rectOf: CGSize(width: 10,height: 40))
        leftline.strokeColor = SKColor.white
        leftline.fillColor = SKColor.white
        leftline.alpha = 0.4
        leftline.name = "leftline"
        leftline.zPosition = 10
        leftline.position.x = -187.5
        leftline.position.y = 700
        addChild(leftline)
        
        let rightline = SKShapeNode(rectOf: CGSize(width: 10,height: 40))
        rightline.strokeColor = SKColor.white
        rightline.fillColor = SKColor.white
        rightline.alpha = 0.4
        rightline.name = "rightline"
        rightline.zPosition = 10
        rightline.position.x = 187.5
        rightline.position.y = 700
        addChild(rightline)
    }
    func showline()
    {
        enumerateChildNodes(withName: "leftline", using: {(roadline, stop) in
        let line = roadline as! SKShapeNode
        line.position.y -= 30
        })
        enumerateChildNodes(withName: "rightline", using: {(roadline, stop) in
            let line = roadline as! SKShapeNode
            line.position.y -= 30
        })
        enumerateChildNodes(withName: "orangeCar", using: {(leftCar, stop) in
            let car = leftCar as! SKSpriteNode
            car.position.y -= 15
        })
        enumerateChildNodes(withName: "greenCar", using: {(rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            car.position.y -= 15
        })
    }
    func remove()
    {
        for child in children
        {
            if child.position.y < -self.size.height - 100
            {
                child.removeFromParent()
            }
        }
    }
    func moveleftCar(leftSide: Bool)
    {
        if leftSide
        {
            leftCar.position.x -= 20
            if leftCar.position.x < leftCarminimumX
            {
                leftCar.position.x = leftCarminimumX
            }
        }
        else
        {
            leftCar.position.x += 20
            if leftCar.position.x > leftCarmaximumX
            {
                leftCar.position.x = leftCarmaximumX
            }
        }
    }
    func moverightCar(rightSide: Bool)
    {
        if rightSide
        {
            rightCar.position.x -= 20
            if rightCar.position.x < rightCarminimumX
            {
                rightCar.position.x = rightCarminimumX
            }
        }
        else
        {
            rightCar.position.x += 20
            if rightCar.position.x > rightCarmaximumX
            {
                rightCar.position.x = rightCarmaximumX
            }
        }
    }
    //左障礙車
    func leftItems()
    {
        let leftitem: SKSpriteNode
        let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 6)
        switch Int(randomNumber)
        {
            case 1...6:
                leftitem = SKSpriteNode(imageNamed: "orangeCar")
                leftitem.name = "orangeCar"
            break
            default:
                leftitem = SKSpriteNode(imageNamed: "orangeCar")
                leftitem.name = "orangeCar"
        }
        leftitem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leftitem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 4)
        switch Int(randomNum)
        {
            case 1...2:
            leftitem.position.x = -280
            break
            case 3...4:
            leftitem.position.x = -100
            break
            default:
            leftitem.position.x = -280
            break
        }
        leftitem.position.y = 700
        leftitem.physicsBody = SKPhysicsBody(circleOfRadius: leftitem.size.height / 2)
        leftitem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        leftitem.physicsBody?.collisionBitMask = 0
        leftitem.physicsBody?.affectedByGravity = false
        addChild(leftitem)
    }
    //右障礙車
    func rightItems()
    {
        let rightitem: SKSpriteNode
        let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 6)
        switch Int(randomNumber)
        {
        case 1...6:
            rightitem = SKSpriteNode(imageNamed: "greenCar")
            rightitem.name = "greenCar"
            break
        default:
            rightitem = SKSpriteNode(imageNamed: "greenCar")
            rightitem.name = "greenCar"
        }
        rightitem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightitem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 4)
        switch Int(randomNum)
        {
        case 1...2:
            rightitem.position.x = 280
            break
        case 3...4:
            rightitem.position.x = 100
            break
        default:
            rightitem.position.x = 280
            break
        }
        rightitem.position.y = 700
        rightitem.physicsBody = SKPhysicsBody(circleOfRadius: rightitem.size.height / 2)
        rightitem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        rightitem.physicsBody?.collisionBitMask = 0
        rightitem.physicsBody?.affectedByGravity = false
        addChild(rightitem)
    }
    func afterCollision()
    {   if gameSetting.highScore < score
        {
            gameSetting.highScore = score
        }
        let menuScene = SKScene(fileNamed: "GameMenu")!
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
    }
    func increaseScore()
    {
        if !stopEverything
        {
            score += 1
            scoreText.text = String(score)
        }
    }
}