import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	var DEFAULT_PADDLE_WIDTH: CGFloat = 0
	var DEFAULT_PADDLE_HEIGHT: CGFloat = 0
	
	var DEFAULT_SCALAR_TO_FIT: CGFloat = 3.55902
	var DEFAULT_PADDING: CGFloat = 0
    
	// Time management
	private var lastUpdateTime : TimeInterval = 0
	
	// Static sprites
	// These sprites will not move
	var centerLine: SKSpriteNode!
	var playerGoal: SKSpriteNode!
	var enemyGoal: SKSpriteNode!
	
	// Dynamic sprites
	// These sprites will move
	var player: SKSpriteNode!
	var enemy: SKSpriteNode!
	
	var ball: SKShapeNode!
	var ballRadius: CGFloat!
	
	var poo: String = ""
		
	// INIT SCENE
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
		
		// Set background color
		backgroundColor = UIColor(red: 24/255, green: 20/255, blue: 37/255, alpha: 1)
		
		// Set default paddle dimensions
		DEFAULT_PADDLE_WIDTH = frame.size.width / 4
		DEFAULT_PADDLE_HEIGHT = DEFAULT_PADDLE_WIDTH / 5
		
		DEFAULT_PADDING = (DEFAULT_PADDLE_WIDTH * DEFAULT_SCALAR_TO_FIT) - (DEFAULT_PADDLE_HEIGHT / 2)
		
		// STATIC SPRITES
		
		// Center line divider
		centerLine = SKSpriteNode(color: UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_HEIGHT / 4))
		centerLine.position = CGPoint(x: 0, y: 0)
		addChild(centerLine!)
		
		// Player & Enemy sore zones
		playerGoal = SKSpriteNode(color: UIColor(red: 0, green: 153/255, blue: 219/255, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_HEIGHT))
//		playerGoal.position = CGPoint(x: 0, y: (-1 * (frame.size.height / 2)) + (playerGoal.size.height / 2))
		playerGoal.position = CGPoint(x: 0, y: -DEFAULT_PADDING)
		addChild(playerGoal!)
		
		enemyGoal = SKSpriteNode(color: UIColor(red: 1, green: 0, blue: 68/255, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_HEIGHT))
//		enemyGoal.position = CGPoint(x: 0 , y: (frame.size.height / 2) - (enemyGoal.size.height / 2))
		enemyGoal.position = CGPoint(x: 0, y: DEFAULT_PADDING)
		addChild(enemyGoal!)
		
		// INTERACTIVE SPRITES
		
		// Player sprite
		player = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		player.position = CGPoint(x: 0, y: -DEFAULT_PADDING + 100)
		
		// Player physics body
		player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
		player.physicsBody?.affectedByGravity = false
		
		addChild(player!)
		
		// Enemy sprite
		enemy = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		enemy.position = CGPoint(x: 0, y: DEFAULT_PADDING - 100)
		
		// Enemy physics body
		enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
		enemy.physicsBody?.affectedByGravity = false
		
		addChild(enemy!)
		
		// Ball shape
		ballRadius = DEFAULT_PADDLE_HEIGHT / 2
		ball = SKShapeNode(circleOfRadius: ballRadius)
		ball.position = CGPoint(x: 0, y: 0)
		ball.fillColor = .white
		
		// Ball physics body
		ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
		ball.physicsBody?.affectedByGravity = false
		
		addChild(ball!)
	}
    
	// UPDATE GAME
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
				
		// Set the delta time
		let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
    }
	
	// INPUT MANAGEMENT
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			
			if location.x + (player.size.width / 2) >= frame.size.width / 2 {
				player.position.x = (frame.size.width / 2) - (player.size.width / 2)
			} else if location.x - (player.size.width / 2) <= -(frame.size.width / 2) {
				player.position.x = -(frame.size.width / 2) + (player.size.width / 2)
			} else {
				player.position.x = location.x
			}
		}
	}
}
