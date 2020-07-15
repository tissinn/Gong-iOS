import SpriteKit
import GameplayKit

let WALL_MASK: UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// Background sprites
	var centerLineLeft: SKSpriteNode!
	var centerLineRight: SKSpriteNode!
	var centerCircle: SKShapeNode!
		
	// Player enemy & ball
	var player: PaddleSprite!
	var enemy: PaddleSprite!
	var ball: BallSprite!
	
	var playerScored = false
	var enemyScored = false
		
	// Executes once the scene is presented
	override func sceneDidLoad() {		
		// Set background color
		backgroundColor = UIColor(red: 24/255, green: 20/255, blue: 37/255, alpha: 1)
		
		// Set default paddle values
		let screen = frame; setDefaultPaddleValues(screen)
		
		// Set contact delegate
		physicsWorld.contactDelegate = self
		
		// Create border physics bodies
		let leftWall = SKNode()
		leftWall.position.x = -(frame.size.width / 2)
		leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -(frame.size.height / 2)), to: CGPoint(x: 0, y: (frame.size.height / 2)))
		leftWall.physicsBody?.categoryBitMask = WALL_MASK
		addChild(leftWall)

		let rightWall = SKNode()
		rightWall.position.x = (frame.size.width / 2)
		rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -(frame.size.height / 2)), to: CGPoint(x: 0, y: (frame.size.height / 2)))
		rightWall.physicsBody?.categoryBitMask = WALL_MASK
		addChild(rightWall)
		
		// Center divider
		centerLineLeft = SKSpriteNode(color: UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1), size: CGSize(width: (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2), height: DEFAULT_PADDLE_HEIGHT / 4))
		centerLineLeft.position = CGPoint(x: -(frame.size.width / 2) + (centerLineLeft.size.width / 2), y: 0)
		addChild(centerLineLeft!)
		
		centerLineRight = SKSpriteNode(color: UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1), size: CGSize(width: (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2), height: DEFAULT_PADDLE_HEIGHT / 4))
		centerLineRight.position = CGPoint(x: (frame.size.width / 2) - (centerLineRight.size.width / 2), y: 0)
		addChild(centerLineRight!)
		
		centerCircle = SKShapeNode(circleOfRadius: DEFAULT_PADDLE_WIDTH / 2)
		centerCircle.position = CGPoint(x: 0, y: 0)
		centerCircle.fillColor = .clear
		centerCircle.lineWidth = DEFAULT_PADDLE_HEIGHT / 4
		centerCircle.strokeColor = UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1)
		addChild(centerCircle!)
		
		// Player enemy & ball
		player = PaddleSprite(frame: frame, position: .Bottom, ai: false)
		addChild(player.paddlePath!)
		addChild(player.paddleLeftEnd!)
		addChild(player.paddleRightEnd!)
		addChild(player.sprite!)
		addChild(player.scoreLabel!)

		enemy = PaddleSprite(frame: frame, position: .Top, ai: true)
		addChild(enemy.paddlePath!)
		addChild(enemy.paddleLeftEnd!)
		addChild(enemy.paddleRightEnd!)
		addChild(enemy.sprite!)
		addChild(enemy.scoreLabel!)
		
		ball = BallSprite()
		addChild(ball.shape!)
	
		ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: -300)
	}
	
	// Update callback
	private var lastTime: TimeInterval = 0
	override func update(_ currentTime: TimeInterval) {
		let delta = CGFloat(currentTime - lastTime)
		lastTime = currentTime
		
		player.update(delta)
		enemy.update(delta)
		
		if (ball.shape.physicsBody?.velocity.dy)! > 0 {
			var destination = ball.shape.position.x
			
			if destination < enemy.sprite.position.x {
				if destination - (DEFAULT_PADDLE_WIDTH / 2) < -(frame.size.width / 2) {
					destination = -(frame.size.width / 2) + (DEFAULT_PADDLE_WIDTH / 2)
				}
			} else if destination > enemy.sprite.position.x {
				if destination + (DEFAULT_PADDLE_WIDTH / 2) > (frame.size.width / 2) {
					destination = (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2)
				}
			}
			
			if ball.shape.position.y < enemy.sprite.position.y {
				enemy.sprite.run(.moveTo(x: destination, duration: 0.175))
			}
		}
		
		// If player scores
		if ball.shape.position.y - (DEFAULT_PADDLE_HEIGHT / 2) > frame.size.height / 2 && !playerScored {
			playerScored = true
			player.score += 1
			
			BALL_SPEED = BALL_BASE_SPEED
			
			ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
			
			let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
			
			let impact = SKAction.run({
				hapticHeavy.impactOccurred()
			})
			let impactWait = SKAction.wait(forDuration: 0.15)
			let fadeOut = SKAction.fadeOut(withDuration: 0)
			let wait = SKAction.wait(forDuration: 1)
			let move = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0)
			let fadeIn = SKAction.fadeIn(withDuration: 1)
			
			let serve = SKAction.run({
				self.ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
				self.playerScored = false
			})
			
			ball.shape.run(.sequence([ impact, impactWait, impact, impactWait, impact, fadeOut, wait, move, fadeIn, serve ]))
		}
		
		// If enemy scores
		if ball.shape.position.y + (DEFAULT_PADDLE_HEIGHT / 2) < -(frame.size.height / 2) && !enemyScored {
			enemyScored = true
			enemy.score += 1
			
			BALL_SPEED = BALL_BASE_SPEED
			
			ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
			
			let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
			
			let impact = SKAction.run({
				hapticHeavy.impactOccurred()
			})
			let impactWait = SKAction.wait(forDuration: 0.15)
			let fadeOut = SKAction.fadeOut(withDuration: 0)
			let wait = SKAction.wait(forDuration: 1)
			let move = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0)
			let fadeIn = SKAction.fadeIn(withDuration: 1)
			
			let serve = SKAction.run({
				self.ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: -300)
				self.enemyScored = false
			})
			
			ball.shape.run(.sequence([ impact, impactWait, impact, impactWait, impact, fadeOut, wait, move, fadeIn, serve ]))
		}
	}
	
	// Process and handle input
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			
			if location.x + (DEFAULT_PADDLE_WIDTH / 2) > (frame.size.width / 2) {
				player.sprite.position.x = (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2)
			} else if location.x - (DEFAULT_PADDLE_WIDTH / 2) < -(frame.size.width / 2) {
				player.sprite.position.x = -(frame.size.width / 2) + (DEFAULT_PADDLE_WIDTH / 2)
			} else {
				player.input(location)
			}
		}
	}
	
	// Process contacts
	func didBegin(_ contact: SKPhysicsContact) {
		let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		// Haptic generators
		let hapticLight = UIImpactFeedbackGenerator(style: .light)
		let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
		
		// Detect contacts here
		switch contactMask {
		case BALL_MASK | WALL_MASK: hapticLight.impactOccurred()
		// Ball collides with Player
		case BALL_MASK | PADDLE_MASK:
			hapticHeavy.impactOccurred()
			
			// Calculate the intersection of the ball
			let relativeIntersect = player.sprite.position.x - ball.shape.position.x
			let normalizedIntersect = relativeIntersect / (DEFAULT_PADDLE_WIDTH / 2)
			let bounceAngle = normalizedIntersect * BALL_MAX_ANGLE
			
			// Set the ball's velocity
			if normalizedIntersect <= 1 && normalizedIntersect >= -1 && ball.shape.position.y >= player.sprite.position.y {
				let ballDx = BALL_SPEED * -sin(bounceAngle)
				var ballDy = BALL_SPEED *  cos(bounceAngle)
				
				if ballDy < BALL_MIN_Y_INCREMENT { ballDy = BALL_MIN_Y_INCREMENT }
				ball.shape.physicsBody?.velocity = CGVector(dx: ballDx, dy: ballDy)
			}
			
			// Increase ball speed
			BALL_SPEED += BALL_SPEED_INCREMENT
			
			break
		// Ball collides with AI
		case BALL_MASK | PADDLE_AI_MASK:
			hapticHeavy.impactOccurred()
			
			// Calculate new ball direction
			let relativeIntersect = enemy.sprite.position.x - ball.shape.position.x
			let normalizedIntersect = relativeIntersect / (DEFAULT_PADDLE_WIDTH / 2)
			let bounceAngle = normalizedIntersect *  BALL_MAX_ANGLE
			
			// If ball hits bottom of the paddle
			if normalizedIntersect <= 1 && normalizedIntersect >= -1 && ball.shape.position.y <= enemy.sprite.position.y {
				let ballDx = BALL_SPEED * -sin(bounceAngle)
				var ballDy = BALL_SPEED *  cos(bounceAngle)
				
				if ballDy < BALL_MIN_Y_INCREMENT { ballDy = BALL_MIN_Y_INCREMENT }
				ball.shape.physicsBody?.velocity = CGVector(dx: ballDx, dy: -ballDy)
			}
			
			// Increase ball speed
			BALL_SPEED += BALL_SPEED_INCREMENT
			
			break
		default: break
		}
	}
}
