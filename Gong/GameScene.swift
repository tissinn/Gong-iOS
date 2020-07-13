import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	// Constants
	let DEFAULT_PADDLE_WIDTH: CGFloat = 80
	let DEFAULT_PADDLE_HEIGHT: CGFloat = 16
	
	// Input management
	var touching = false
	var touchPosition: CGPoint = CGPoint(x: 0, y: 0)
    
	// Time management
	private var lastUpdateTime : TimeInterval = 0
	
	// Sprites
	var centerLine: SKSpriteNode!
	var playerGoal: SKSpriteNode!
	var enemyGoal: SKSpriteNode!
	
	var player: SKSpriteNode!
	var enemy: SKSpriteNode!
		
	// INIT SCENE
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
		
		// Set background color
		backgroundColor = UIColor(red: 24/255, green: 20/255, blue: 37/255, alpha: 1)
		
		// Center line divider
		centerLine = SKSpriteNode(color: UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1), size: CGSize(width: frame.size.width, height: 5))
		centerLine.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
		addChild(centerLine!)
		
		// Player & Enemy sore zones
		playerGoal = SKSpriteNode(color: UIColor(red: 0, green: 153/255, blue: 219/255, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_HEIGHT))
		playerGoal.position = CGPoint(x: frame.size.width / 2, y: playerGoal.size.height / 2)
		addChild(playerGoal!)
		
		enemyGoal = SKSpriteNode(color: UIColor(red: 1, green: 0, blue: 68/255, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_HEIGHT))
		enemyGoal.position = CGPoint(x: frame.size.width / 2 , y: frame.size.height - enemyGoal.size.height / 2)
		addChild(enemyGoal!)
		
		// Player & Enemy
		player = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		player.position = CGPoint(x: (size.width / 2), y: 100)
		addChild(player!)
		
		enemy = SKSpriteNode(color: .white, size: CGSize(width: DEFAULT_PADDLE_WIDTH, height: DEFAULT_PADDLE_HEIGHT))
		enemy.position = CGPoint(x: (size.width / 2), y: frame.size.height - 100)
		addChild(enemy!)
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
			
			if location.x + (player.size.width / 2) >= frame.size.width {
				player.position.x = frame.size.width - (player.size.width / 2)
			} else if location.x - (player.size.width / 2) <= 0 {
				player.position.x = player.size.width / 2
			} else {
				player.position.x = location.x
			}
		}
	}
}
