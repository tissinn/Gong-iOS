import SpriteKit
import GameplayKit

let BALL_MASK: UInt32 = 0x1 << 3

var BALL_BASE_SPEED: CGFloat = 0
var BALL_SPEED: CGFloat = BALL_BASE_SPEED
let BALL_MIN_Y_INCREMENT: CGFloat = 150
let BALL_SPEED_INCREMENT: CGFloat = 10
let BALL_SERVE_SPEED: CGFloat = 300
let BALL_EMISSION_RATE: CGFloat = 150

let BALL_MAX_ANGLE: CGFloat = CGFloat.pi / 3

class BallSprite {
	
	public var sprite: SKSpriteNode!
	public let radius: CGFloat = DEFAULT_PADDLE_HEIGHT / 2
	
	public init() {
		// Create shape
		sprite = SKSpriteNode(texture: SKTexture(imageNamed: "Ball"), size: CGSize(width: radius * 2, height: radius * 2))
		sprite.position = CGPoint(x: 0, y: 0)
		
		// Add physics body
		sprite.physicsBody = SKPhysicsBody(circleOfRadius: radius)
		sprite.physicsBody?.isDynamic = true
		sprite.physicsBody?.affectedByGravity = false
		sprite.physicsBody?.friction = 0
		sprite.physicsBody?.restitution = 1
		sprite.physicsBody?.linearDamping = 0
		sprite.physicsBody?.angularDamping = 0
		sprite.physicsBody?.categoryBitMask = BALL_MASK
		sprite.physicsBody?.contactTestBitMask = PADDLE_MASK | PADDLE_AI_MASK | WALL_MASK
	}
	
}
