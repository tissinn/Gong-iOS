import SpriteKit
import GameplayKit

let WALL_MASK: UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// Background sprites
	var promptBackground: SKSpriteNode!
	var promptBox: SKSpriteNode!
	var promptInstruction: SKLabelNode!
	var promptText: SKLabelNode!
	var gameBegan = false
	var gameEnded = true
	
	var centerLineLeft: SKSpriteNode!
	var centerLineRight: SKSpriteNode!
	var centerCircle: SKShapeNode!
		
	// Player enemy & ball
	var player: PaddleSprite!
	var enemy: PaddleSprite!
	var ball: BallSprite!
	
	var playerScored = false
	var enemyScored = false
	var scorePrompt: SKLabelNode!
	
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
		
		// Begin game prompt
		promptBackground = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), size: frame.size)
		promptBackground.position = CGPoint(x: 0, y: 0)
		promptBackground.zPosition = 2
		addChild(promptBackground!)
		
		promptBox = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 1), size: CGSize(width: frame.size.width, height: DEFAULT_PADDLE_WIDTH * 2))
		promptBox.position = CGPoint(x: 0, y: 0)
		promptBox.zPosition = 2
		addChild(promptBox!)
		
		promptInstruction = SKLabelNode(fontNamed: "Montserrat-BLACK")
		promptInstruction.position = CGPoint(x: 0, y: DEFAULT_PADDLE_WIDTH / 3)
		promptInstruction.zPosition = 2
		promptInstruction.text = "FIRST TO 11 WINS"
		promptInstruction.verticalAlignmentMode = .center
		promptInstruction.horizontalAlignmentMode = .center
		promptInstruction.fontColor = .white
		promptInstruction.fontSize = DEFAULT_PADDLE_WIDTH / 2
		addChild(promptInstruction!)
		
		promptText = SKLabelNode(fontNamed: "Montserrat-SemiBold")
		promptText.position = CGPoint(x: 0, y: -(DEFAULT_PADDLE_WIDTH / 3))
		promptText.zPosition = 2
		promptText.text = "Tap to begin the game."
		promptText.verticalAlignmentMode = .center
		promptText.horizontalAlignmentMode = .center
		promptText.fontColor = .white
		promptText.fontSize = DEFAULT_PADDLE_WIDTH / 3
		addChild(promptText!)
		
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
		centerCircle.lineWidth = DEFAULT_PADDLE_HEIGHT / 3.25
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
		addChild(ball.sprite!)
		
		scorePrompt = SKLabelNode(fontNamed: "FredokaOne-Regular")
		scorePrompt.text = "GONG!"
		scorePrompt.zPosition = 2
		scorePrompt.fontSize = DEFAULT_PADDLE_WIDTH
		scorePrompt.fontColor = UIColor(red: 254/255, green: 174/255, blue: 52/255, alpha: 1)
		scorePrompt.verticalAlignmentMode = .center
		scorePrompt.horizontalAlignmentMode = .center
		scorePrompt.run(.fadeOut(withDuration: 0))
		addChild(scorePrompt!)
	}
	
	// Update callback
	private var lastTime: TimeInterval = 0
	override func update(_ currentTime: TimeInterval) {
		let delta = CGFloat(currentTime - lastTime)
		lastTime = currentTime
		
		player.update(delta)
		enemy.update(delta)
		
		// Ai follow the ball
		if (ball.sprite.physicsBody?.velocity.dy)! > 0 {
			var destination = ball.sprite.position.x
			
			// If ball is to the left or right of enemy
			if destination < enemy.sprite.position.x {
				if destination - (DEFAULT_PADDLE_WIDTH / 2) < -(frame.size.width / 2) {
					destination = -(frame.size.width / 2) + (DEFAULT_PADDLE_WIDTH / 2)
				}
			} else if destination > enemy.sprite.position.x {
				if destination + (DEFAULT_PADDLE_WIDTH / 2) > (frame.size.width / 2) {
					destination = (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2)
				}
			}
			
			// Check if ball is past the paddle
			if ball.sprite.position.y + ball.radius >= enemy.sprite.position.y - (DEFAULT_PADDLE_HEIGHT / 2) {
				destination = enemy.sprite.position.x
			}
			
			// Move to destination
			enemy.sprite.run(.moveTo(x: destination, duration: PADDLE_AI_DIFFICULTY))
		}
		
		// If player scores
		if ball.sprite.position.y - (DEFAULT_PADDLE_HEIGHT / 2) > frame.size.height / 2 && !playerScored {
			player.score += 1
			
			if player.score >= 11 {
				didEndGame(true)
			} else {
				didScore(false)
			}
		}
		
		// If enemy scores
		if ball.sprite.position.y + (DEFAULT_PADDLE_HEIGHT / 2) < -(frame.size.height / 2) && !enemyScored {
			enemy.score += 1
			
			if enemy.score >= 11 {
				didEndGame(false)
			} else {
				didScore(true)
			}
		}
	}
	
	// Did paddle score
	private func didScore(_ isAi: Bool) {
		if !isAi {
			playerScored = true
		} else {
			enemyScored = true
		}
		
		// Reset ball speed
		BALL_SPEED = BALL_BASE_SPEED
		
		// Reset ball velocity
		ball.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		
		// Show "Gong" label
		do {
			let impact = SKAction.run({
				let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
				hapticHeavy.impactOccurred()
			})
			let fadeIn = SKAction.fadeIn(withDuration: 0)
			let scaleUp = SKAction.scale(by: 2, duration: 0.5)
			let fadeOut = SKAction.run({ self.scorePrompt.run(.fadeOut(withDuration: 0.5)) })
			let wait = SKAction.wait(forDuration: 0.5)
			let scaleDown = SKAction.scale(by: 0.5, duration: 0)
			
			scorePrompt.run(.sequence([ impact, fadeIn, fadeOut, scaleUp, wait, scaleDown ]))
		}
		
		// Sequence 1
		do {
			let initWait = SKAction.wait(forDuration: 0.5)
			let colorBlue = SKAction.run({ self.player.scoreLabel.fontColor = UIColor(red: 0, green: 153/255, blue: 219/255, alpha: 1) })
			let colorRed = SKAction.run({ self.enemy.scoreLabel.fontColor = UIColor(red: 1, green: 0/255, blue: 68/255, alpha: 1) })
			let hit = SKAction.run({
				let hapticLight = UIImpactFeedbackGenerator(style: .light)
				let impact = SKAction.run({
					hapticLight.impactOccurred()
				})
				self.ball.sprite.run(.sequence([ impact ]))
			})
			let scaleUp = SKAction.scale(by: 2, duration: 0.25)
			let scaleDown = SKAction.scale(by: 0.5, duration: 0.25)
			let shake = SKAction.run({
				let duration: Float = 0.25
				let amplitudeX: Float = 10
				let amplitudeY: Float = 6
				let numShakes = duration / 0.04
				var actions: [SKAction] = []
				
				for _ in 1...Int(numShakes) {
					let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
					let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
					let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
					shakeAction.timingMode = SKActionTimingMode.easeOut
					actions.append(shakeAction)
					actions.append(shakeAction.reversed())
				}
				
				if !isAi {
					self.player.scoreLabel.run(.sequence(actions))
				} else {
					self.enemy.scoreLabel.run(.sequence(actions))
				}
			})
			let rumble = SKAction.run({
				let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
				let impact = SKAction.run({
					hapticHeavy.impactOccurred()
				})
				let wait = SKAction.wait(forDuration: 0.15)
				
				self.ball.sprite.run(.sequence([ impact, wait, impact, wait, impact ]))
			})
			let wait = SKAction.wait(forDuration: 0.5)
			let colorReset = SKAction.run({ self.player.scoreLabel.fontColor = UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1); self.enemy.scoreLabel.fontColor = UIColor(red: 90/255, green: 105/255, blue: 136/255, alpha: 1) })


			if !isAi {
				player.scoreLabel.run(.sequence([ initWait, colorBlue, hit, scaleUp, scaleDown, shake, rumble, wait, colorReset ]))
			} else {
				enemy.scoreLabel.run(.sequence([ initWait, colorRed, hit, scaleUp, scaleDown, shake, rumble, wait, colorReset ]))
			}
		}
		
		// Sequence 2
		do {
			let fadeOut = SKAction.fadeOut(withDuration: 0)
			let wait = SKAction.wait(forDuration: 2)
			let move = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0)
			let fadeIn = SKAction.fadeIn(withDuration: 1)
			let serve = SKAction.run({
				// Determine serve direction
				let serveDirection = !isAi ? BALL_SERVE_SPEED : -BALL_SERVE_SPEED
				self.ball.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: serveDirection)
				
				// Reset
				if !isAi { self.playerScored = false } else { self.enemyScored = false }
			})
			
			ball.sprite.run(.sequence([ fadeOut, wait, move, fadeIn, serve ]))
		}
	}
	
	// Either player or enemy won
	private func didEndGame(_ playerWon: Bool) {
		if playerWon {
			promptInstruction.text = "YOU WON \(player.score)-\(enemy.score)"
			promptInstruction.fontColor = UIColor(red: 0, green: 153/255, blue: 219/255, alpha: 1)
			promptText.text = "Tap to play again."
		} else {
			promptInstruction.text = "YOU LOSE \(enemy.score)-\(player.score)"
			promptInstruction.fontColor = UIColor(red: 1, green: 0/255, blue: 68/255, alpha: 1)
			promptText.text = "Tap to try again."
		}
		
		// Reset ball speed
		BALL_SPEED = BALL_BASE_SPEED
		
		// Reset ball velocity
		ball.sprite.run(.fadeOut(withDuration: 0))
		ball.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		ball.sprite.position = CGPoint(x: 0, y: 0)
		
		// Reset prompt
		gameBegan = false
		gameEnded = false
		
		let fadeInSequence = SKAction.sequence([ .wait(forDuration: 1), .fadeIn(withDuration: 1), .run({ self.gameEnded = true; self.ball.sprite.run(.fadeIn(withDuration: 0)) }) ])
		
		promptBackground.run(.fadeIn(withDuration: 1))
		promptBox.run(fadeInSequence)
		promptText.run(fadeInSequence)
		promptInstruction.run(fadeInSequence)
	}
	
	// Just touched screen
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if !gameBegan && gameEnded {
			gameBegan = true
			
			// Reset scores
			player.score = 0
			enemy.score = 0
			
			// Impulse
			let haptic = UIImpactFeedbackGenerator(style: .heavy)
			haptic.impactOccurred()
			
			// Remove prompt
			promptBackground.run(.fadeOut(withDuration: 0.5))
			promptBox.run(.fadeOut(withDuration: 0.5))
			promptInstruction.run(.fadeOut(withDuration: 0.5))
			promptText.run(.fadeOut(withDuration: 0.5))
			
			// Serve ball
			ball.sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -BALL_SERVE_SPEED)
		}
	}
	
	// Process and handle input
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			
			if gameBegan {
				if location.x + (DEFAULT_PADDLE_WIDTH / 2) > (frame.size.width / 2) {
					player.sprite.position.x = (frame.size.width / 2) - (DEFAULT_PADDLE_WIDTH / 2)
				} else if location.x - (DEFAULT_PADDLE_WIDTH / 2) < -(frame.size.width / 2) {
					player.sprite.position.x = -(frame.size.width / 2) + (DEFAULT_PADDLE_WIDTH / 2)
				} else {
					player.input(location)
				}
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
			
			// Reflect ball towards enemy
			reflectBall(false)
			
			// Increase ball speed
			BALL_SPEED += BALL_SPEED_INCREMENT
			
			break
		// Ball collides with AI
		case BALL_MASK | PADDLE_AI_MASK:
			hapticHeavy.impactOccurred()
			
			// Reflect ball towards player
			reflectBall(true)
			
			// Increase ball speed
			BALL_SPEED += BALL_SPEED_INCREMENT
			
			break
		default: break
		}
	}
	
	// Calculate ball's direction
	private func reflectBall(_ isAi: Bool) {
		// Calculate the intersection of the ball
		var relativeIntersect: CGFloat = 0
		if !isAi { relativeIntersect = player.sprite.position.x - ball.sprite.position.x }
		else { relativeIntersect = enemy.sprite.position.x - ball.sprite.position.x }
		
		// Normalize the intersection
		var normalizedIntersect = relativeIntersect / (DEFAULT_PADDLE_WIDTH / 2)
		
		// Check if == 0.0
		if normalizedIntersect == 0 {
			let rand = Int.random(in: 1...2)
			if rand == 1 { normalizedIntersect = 0.2 }
			else if rand == 2 { normalizedIntersect = -0.2 }
		}
		
		// Calculate ball's angle
		let bounceAngle = normalizedIntersect * BALL_MAX_ANGLE
		
		// Set the ball's velocity
		if !isAi && normalizedIntersect <= 1 && normalizedIntersect >= -1 && ball.sprite.position.y >= player.sprite.position.y {
			let ballDx = BALL_SPEED * -sin(bounceAngle)
			var ballDy = BALL_SPEED *  cos(bounceAngle)
			
			if ballDy < BALL_MIN_Y_INCREMENT { ballDy = BALL_MIN_Y_INCREMENT }
			ball.sprite.physicsBody?.velocity = CGVector(dx: ballDx, dy: ballDy)
		} else if isAi && normalizedIntersect <= 1 && normalizedIntersect >= -1 && ball.sprite.position.y <= ball.sprite.position.y {
			let ballDx = BALL_SPEED * -sin(bounceAngle)
			var ballDy = BALL_SPEED *  cos(bounceAngle)
			
			if ballDy < BALL_MIN_Y_INCREMENT { ballDy = BALL_MIN_Y_INCREMENT }
			ball.sprite.physicsBody?.velocity = CGVector(dx: ballDx, dy: -ballDy)
		}
	}
}
