//
//  GameScene.swift
//  BlockBuster
//
//  Created by chino on 2016/09/11.
//  Copyright © 2016年 chino. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var paddle: SKSpriteNode!
    var balls = [SKShapeNode]()
    
    let ballRadius: CGFloat = 12.0
    let numberOfBalls = 1
    let ballSpeed: Double = 600.0
    
    let timeLabel = SKLabelNode()
    var startTime = Date()
    
    
    
    //シーンが表示されたら
    override func didMove(to view: SKView) {
        print("x: \(view.frame.maxX), y: \(view.frame.maxY)")
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        /* ラケット */
        self.paddle = SKSpriteNode(color: UIColor.green, size: CGSize(width: 100, height: 20))
        self.paddle.position = CGPoint(x: frame.midX, y: frame.minY+140.0)
        self.paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        self.paddle.physicsBody?.isDynamic = false
        self.addChild(paddle)
        
        /* ボール */
        addBall()
        
        self.timeLabel.position = CGPoint(x: frame.maxX+30.0, y: frame.maxY-30.0)
        self.timeLabel.fontColor = UIColor.white
        self.timeLabel.text = "0"
        self.timeLabel.fontSize = 100
        self.timeLabel.verticalAlignmentMode = .top
        self.timeLabel.horizontalAlignmentMode = .right
        self.addChild(timeLabel)
    }
    
    private func addBall() {
        var directionX: Double = 1.0
        
        for _ in 0..<numberOfBalls {
            let ball = SKShapeNode(circleOfRadius: self.ballRadius)
            ball.position = CGPoint(x: paddle.frame.midX, y: paddle.frame.midY + ballRadius)
            ball.fillColor = UIColor.orange
            ball.strokeColor = UIColor.orange
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
            
            let randX = arc4random_uniform(10) + 10
            let randY = arc4random_uniform(10) + 10
            let vecter = sqrt(Double(randX*randX + randY*randY))

            let speedX = Double(randX) * ballSpeed / vecter
            let speedY = Double(randY) * ballSpeed / vecter
            ball.physicsBody?.velocity = CGVector(dx: speedX * directionX, dy: speedY)
            directionX *= -1
            
            
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.restitution = 1.0
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.friction = 0
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(ball)
            self.balls.append(ball)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if balls.count == 0 {
            startTime = Date()
            addBall()
        } else {
            super.touchesBegan(touches, with: event)
            
            let location = touches.first?.location(in: self)
            let speed: CGFloat = 0.001
            let interval = abs(location!.x - paddle.position.x) * speed
            let duration = TimeInterval(interval)
            let moveAction = SKAction.moveTo(x: location!.x, duration: duration)
            paddle.run(moveAction)
        }
    }
    
    // 当たり判定で呼ばれる
    override func didSimulatePhysics() {
        var removed = [Int]()
        for ball in balls {
            if ball.position.y < paddle.position.y {
                let file = Bundle.main.path(forResource: "spark", ofType: "sks")
                let sparkNode = NSKeyedUnarchiver.unarchiveObject(withFile: file!) as! SKEmitterNode
                sparkNode.position = ball.position
                sparkNode.xScale = 0.3
                sparkNode.yScale = 0.3
                self.addChild(sparkNode)
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.3)
                let remove = SKAction.removeFromParent()
                sparkNode.run(SKAction.sequence([fadeOut, remove]))
                
                removed.append(balls.index(of: ball)!)
                ball.removeFromParent()
            } else {
                let threshold = CGFloat(ballSpeed * 0.1)

                let dx = CGFloat((ball.physicsBody?.velocity.dx)!)
                if abs(dx) < threshold {
                    let velocity_Y = Double((ball.physicsBody?.velocity.dy)!) * 0.8
                    ball.physicsBody?.velocity.dx = CGFloat(sqrt(ballSpeed*ballSpeed - velocity_Y*velocity_Y))
                    ball.physicsBody?.velocity.dy = CGFloat(velocity_Y)
                }

                let dy = CGFloat((ball.physicsBody?.velocity.dy)!)
                if abs(dy) < threshold {
                    let velocity_X = Double((ball.physicsBody?.velocity.dx)!) * 0.8
                    ball.physicsBody?.velocity.dx = CGFloat(velocity_X)
                    ball.physicsBody?.velocity.dy = CGFloat(sqrt(ballSpeed*ballSpeed - velocity_X*velocity_X))
                }
            }
        }
        
        for index in removed {
            balls.remove(at: index)
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if balls.count > 0 {
            timeLabel.text = "\(Date().timeIntervalSince(startTime)*10)"
        }
    }
}
