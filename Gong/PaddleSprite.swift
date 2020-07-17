import SpriteKit

var DEFAULT_PADDLE_WIDTH: CGFloat = 0
var DEFAULT_PADDLE_HEIGHT: CGFloat = 0
var DEFAULT_SCALAR_TO_FIT: CGFloat = 4.446667
var DEFAULT_MARGIN: CGFloat = 0
let DEFAULT_PADDING: CGFloat = 100

let PADDLE_MASK: UInt32 = 0x1 << 1
let PADDLE_AI_MASK: UInt32 = 0x1 << 2
let PADDLE_AI_DIFFICULTY: TimeInterval = 0.095

func setDefaultPaddleValues(_ frame: CGRect) {
	DEFAULT_PADDLE_WIDTH = frame.size.width / 5
	DEFAULT_PADDLE_HEIGHT = DEFAULT_PADDLE_WIDTH / 5
	DEFAULT_MARGIN = (DEFAULT_PADDLE_WIDTH * DEFAULT_SCALAR_TO_FIT)
	BALL_BASE_SPEED = DEFAULT_MARGIN
}

enum PaddlePosition {
	case Top
	case Bottom
}

class PaddleSprite {
	
	public var sprite: SKSpriteNode!
	public var usesAi: Bool = false
	
	private var previous = CGPoint(x: 0, y: 0)
	public var velocity = CGVector(dx: 0, dy: 0)
	
	public var paddlePath: SKShapeNode!
	public var paddleLeftEnd: SKShapeNode!
	public var paddleRightEnd: SKShapeNode!
	
	public var score: Int = 0
	public var scoreLabel: SKLabelNode!

	public init(frame: CGRect, position: PaddlePosition, ai: Bool) {
		// Create sprite
		sprite = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		
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
		
		// Create score label
		scoreLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
		scoreLabel.text = "\(score)"
		scoreLabel.position = CGPoint(x: 0, y: (DEFAULT_PADDING - DEFAULT_MARGIN) / 2)
		scoreLabel.fontSize = 2 * (DEFAULT_PADDLE_WIDTH / 3)
		scoreLabel.fontColor = UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1)
		scoreLabel.horizontalAlignmentMode = .center
		scoreLabel.verticalAlignmentMode = .center
		
		// Set paddle & label positions
		if position == .Top {
			sprite.position = CGPoint(x: 0, y: DEFAULT_MARGIN - DEFAULT_PADDING)
			scoreLabel.position = CGPoint(x: 0, y: -((DEFAULT_PADDING - DEFAULT_MARGIN) / 2))
		} else if position == .Bottom {
			sprite.position = CGPoint(x: 0, y: -DEFAULT_MARGIN + DEFAULT_PADDING)
			scoreLabel.position = CGPoint(x: 0, y: (DEFAULT_PADDING - DEFAULT_MARGIN) / 2)
		}
		
		// Create the paddle path graphic
		paddlePath = SKShapeNode(rectOf: CGSize(width: frame.size.width - DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT / 8))
		paddlePath.position = sprite.position
		paddlePath.strokeColor = .clear
		
		paddleLeftEnd = SKShapeNode(circleOfRadius: DEFAULT_PADDLE_HEIGHT / 4)
		paddleLeftEnd.position = CGPoint(x: -(frame.size.width / 2) + (DEFAULT_PADDLE_WIDTH / 2), y: sprite.position.y)
		paddleLeftEnd.strokeColor = .clear
		
		paddleRightEnd = SKShapeNode(circleOfRadius: DEFAULT_PADDLE_HEIGHT / 4)
		paddleRightEnd.position = CGPoint(x: (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2), y: sprite.position.y)
		paddleRightEnd.strokeColor = .clear
		
		if !ai {
			paddlePath.fillColor = UIColor(red: 0, green: 153/255, blue: 219/255, alpha: 1)
			paddleLeftEnd.fillColor = UIColor(red: 0/255, green: 153/255, blue: 219/255, alpha: 1)
			paddleRightEnd.fillColor = UIColor(red: 0/255, green: 153/255, blue: 219/255, alpha: 1)
		} else {
			paddlePath.fillColor = UIColor(red: 1, green: 0/255, blue: 68/255, alpha: 1)
			paddleLeftEnd.fillColor = UIColor(red: 1, green: 0/255, blue: 68/255, alpha: 1)
			paddleRightEnd.fillColor = UIColor(red: 1, green: 0/255, blue: 68/255, alpha: 1)
		}
	}
	
	public func update(_ delta: CGFloat) {
		scoreLabel.text = "\(score)"
		
		velocity = CGVector(dx: sprite.position.x - previous.x, dy: sprite.position.y - previous.y)
		previous = sprite.position
	}
	
	public func input(_ location: CGPoint) {
		if !usesAi {
			sprite.position.x = location.x
		}
	}
}
