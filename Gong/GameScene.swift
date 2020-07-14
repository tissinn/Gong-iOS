import SpriteKit
import GameplayKit

let WALL_MASK: UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// Sprites
	var player: PaddleSprite!
	var enemy: PaddleSprite!
	var ball: BallSprite!
	
	var intersectLabel: SKLabelNode!
	
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
		
		// Create sprites
		player = PaddleSprite(position: .Bottom, ai: false)
		addChild(player.sprite!)

		enemy = PaddleSprite(position: .Top, ai: true)
		addChild(enemy.sprite!)
		
		ball = BallSprite()
		addChild(ball.shape!)
		
		intersectLabel = SKLabelNode()
		intersectLabel.position = CGPoint(x: 0, y: 0)
		intersectLabel.horizontalAlignmentMode = .center
		intersectLabel.fontSize = 24
		intersectLabel.fontColor = .white
		addChild(intersectLabel)
		
		ball.shape.physicsBody?.velocity = CGVector(dx: 0, dy: -300)
	}
	
	// Update callback
	override func update(_ currentTime: TimeInterval) {
		if (ball.shape.physicsBody?.velocity.dy)! > 0 {
			enemy.sprite.run(.moveTo(x: ball.shape.position.x, duration: 0.15))
		} else {
			enemy.sprite.run(.moveTo(x: 0, duration: 5))
		}
	}
	
	// Process and handle input
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			player.input(location)
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
			
			// Calculate new ball direction
			let relativeIntersect = player.sprite.position.x - ball.shape.position.x
			let normalizedIntersect = (relativeIntersect / (DEFAULT_PADDLE_WIDTH / 2))
			
			// If ball hits the top face of the paddle
			if normalizedIntersect <= 1 && normalizedIntersect >= -1 {
				ball.shape.physicsBody?.velocity.dx = (-1 * (normalizedIntersect * BALL_SPEED))
			}
			
			print(relativeIntersect)
			
			ball.shape.physicsBody?.velocity.dy = BALL_SPEED
			
			break
		// Ball collides with AI
		case BALL_MASK | PADDLE_AI_MASK:
			hapticHeavy.impactOccurred()
			
			// Calculate new ball direction
			let relativeIntersect = enemy.sprite.position.x - ball.shape.position.x
			let normalizedIntersect = (relativeIntersect / (DEFAULT_PADDLE_WIDTH / 2))
			
			// If ball hits bottom of the paddle
			if normalizedIntersect <= 1 && normalizedIntersect >= -1 {
				ball.shape.physicsBody?.velocity.dx = (-1 * (normalizedIntersect * BALL_SPEED))
			}
			
			print(relativeIntersect)

			ball.shape.physicsBody?.velocity.dy = -BALL_SPEED
			break
		default: break
		}
	}
}
