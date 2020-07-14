import SpriteKit

var DEFAULT_PADDLE_WIDTH: CGFloat = 0
var DEFAULT_PADDLE_HEIGHT: CGFloat = 0
var DEFAULT_SCALAR_TO_FIT: CGFloat = 3.55902
var DEFAULT_PADDING: CGFloat = 0

let PADDLE_MASK: UInt32 = 0x1 << 1
let PADDLE_AI_MASK: UInt32 = 0x1 << 2

func setDefaultPaddleValues(_ frame: CGRect) {
	DEFAULT_PADDLE_WIDTH = frame.size.width / 4
	DEFAULT_PADDLE_HEIGHT = DEFAULT_PADDLE_WIDTH / 5
	DEFAULT_PADDING = (DEFAULT_PADDLE_WIDTH * DEFAULT_SCALAR_TO_FIT)
}

enum PaddlePosition {
	case Top
	case Bottom
}

class PaddleSprite {
	
	public var sprite: SKSpriteNode!
	public var usesAi: Bool = false
	
	public var dx: CGFloat = 0

	public var left: CGFloat = 0
	public var right: CGFloat = 0
	public var top: CGFloat = 0
	public var bottom: CGFloat = 0
	
	public init(position: PaddlePosition, ai: Bool) {
		// Create sprite
		sprite = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		
		// Set position
		if position == .Top {
			sprite.position = CGPoint(x: 0, y: DEFAULT_PADDING - 100)
		} else if position == .Bottom {
			sprite.position = CGPoint(x: 0, y: -DEFAULT_PADDING + 100)
		}
		
		// Create physics body
		sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
		sprite.physicsBody?.isDynamic = false
		sprite.physicsBody?.affectedByGravity = false
		sprite.physicsBody?.friction = 0
		sprite.physicsBody?.restitution = 0
		
		// Set masks
		if !ai {
			sprite.physicsBody?.categoryBitMask = PADDLE_MASK
		} else {
			sprite.physicsBody?.categoryBitMask = PADDLE_AI_MASK
		}
	}
	
	public func input(_ location: CGPoint) {
		if !usesAi {
			sprite.position.x = location.x
		}
	}
}
