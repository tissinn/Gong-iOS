import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	
	var scene: GameScene!
	var defaultBgColor = UIColor()

	// Executed once the view is loaded
    override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create & configure the view
		let spriteKitView = view as? SKView
		spriteKitView?.isMultipleTouchEnabled = false
		spriteKitView?.showsFPS = true
		spriteKitView?.showsNodeCount = true
		
		// Create & configure the scene
		scene = GameScene(size: spriteKitView!.bounds.size)
		scene.scaleMode = .aspectFit
		
		// Present scene to the view
		spriteKitView?.presentScene(scene)
    }

	// Disable auto rotation
    override var shouldAutorotate: Bool {
        return false
    }

	// Only support portrait mode
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
    }

	// Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
