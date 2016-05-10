import UIKit

class SwiftSWRevealViewController: SWRevealViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PreferencesManager.loadValueForKey("username") == nil || PreferencesManager.loadValueForKey("userid") == nil {
            performSegueWithIdentifier("toLogin", sender: self)
            return
        }
    }
}
