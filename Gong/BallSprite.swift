import SpriteKit
import GameplayKit

let BALL_MASK: UInt32 = 0x1 << 3

let BALL_BASE_SPEED: CGFloat = 350
var BALL_Y_SPEED: CGFloat = 350
let BALL_MAX_ANGLE: CGFloat = CGFloat.pi / 2

class BallSprite {
	
	public var shape: SKShapeNode!
	public let radius: CGFloat = DEFAULT_PADDLE_HEIGHT / 2
	
	public init() {
		// Create shape
		shape = SKShapeNode(circleOfRadius: radius)
		shape.fillColor = .white
		shape.strokeColor = .clear
		shape.position = CGPoint(x: 0, y: 0)
		
		// Add physics body
		shape.physicsBody = SKPhysicsBody(circleOfRadius: radius)
		shape.physicsBody?.isDynamic = true
		shape.physicsBody?.affectedByGravity = false
		shape.physicsBody?.friction = 0
		shape.physicsBody?.restitution = 1
		shape.physicsBody?.linearDamping = 0
		shape.physicsBody?.angularDamping = 0
		shape.physicsBody?.categoryBitMask = BALL_MASK
		shape.physicsBody?.contactTestBitMask = PADDLE_MASK | PADDLE_AI_MASK | WALL_MASK
	}
	
}
