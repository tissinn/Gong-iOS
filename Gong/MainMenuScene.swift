import SpriteKit

class MainMenuScene: SKScene {
	
	var logo: SKSpriteNode!
	var playText: SKLabelNode!
		
	// Executes once scene is presented
	override func sceneDidLoad() {
		setDefaultPaddleValues(frame)
		
		// Set background color
		backgroundColor = UIColor(red: 24/255, green: 20/255, blue: 37/255, alpha: 1)
		
		// Main menu logo
		logo = SKSpriteNode(texture: SKTexture(imageNamed: "Logo"), size: CGSize(width: frame.size.width, height: frame.size.width / 2))
		logo.position.y = frame.size.height / 4
		addChild(logo)
		
		// Play logo
		playText = SKLabelNode(fontNamed: "Montserrat-Black")
		playText.text = "TAP ANYWHERE TO PLAY"
		playText.fontColor = UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1)
		playText.fontSize = DEFAULT_PADDLE_HEIGHT * 1.5
		playText.position.y = -(frame.size.height / 4)
		addChild(playText!)
	}
	
	// Process input
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let fadeTransition = SKTransition.fade(withDuration: 1)

		let gameScene = GameScene(size: frame.size)
		gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		gameScene.scaleMode = .aspectFill

		self.view?.presentScene(gameScene, transition: fadeTransition)
	}
}
