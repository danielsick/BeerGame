import UIKit

class HostGameViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var gameNameLabel: UITextField!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var playersStepper: UIStepper! {
        didSet {
            playersLabel.text = Int(playersStepper.value).description
        }
    }
    
    @IBAction func playerStepperValueChanged(sender: UIStepper) {
        playersLabel.text = Int(sender.value).description
    }
    
    @IBOutlet weak var maxWeekLabel: UILabel!
    @IBOutlet weak var maxWeekStepper: UIStepper! {
        didSet {
            maxWeekLabel.text = Int(maxWeekStepper.value).description
        }
    }
    @IBAction func maxWeekStepperValueChanged(sender: UIStepper) {
        maxWeekLabel.text = Int(sender.value).description
    }
    
    @IBOutlet weak var startInvLabel: UILabel!
    @IBOutlet weak var startInvStepper: UIStepper! {
        didSet {
            startInvLabel.text = Int(startInvStepper.value).description
        }
    }
    @IBAction func startInvStepperValueChanged(sender: UIStepper) {
        startInvLabel.text = Int(sender.value).description
    }
    
    @IBOutlet weak var backorderCostLabel: UILabel!
    @IBOutlet weak var backorderCostStepper: UIStepper! {
        didSet {
            backorderCostLabel.text = Double(backorderCostStepper.value).description
        }
    }
    @IBAction func backordercostStepperValueChanged(sender: UIStepper) {
        backorderCostLabel.text = Double(sender.value).description + "$"
    }
    
    @IBOutlet weak var invCostLabel: UILabel!
    @IBOutlet weak var invCostStepper: UIStepper! {
        didSet {
            invCostLabel.text = Double(invCostStepper.value).description
        }
    }
    @IBAction func invCostStepperValueChanged(sender: UIStepper) {
        invCostLabel.text = Double(sender.value).description + "$"
    }
    
    @IBAction func startButtonPressed(sender: UIBarButtonItem) {
        // Display error if the user didn't specify a name for the game
        guard let gameName = gameNameLabel.text where gameName != "" else {
            let alert = UIAlertController(title: "Error", message: "Please enter a name for the game.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true) { }
            return
        }
        
        // Create new game in database
        let game = Game(name: gameName, maximalPlayerCount: Int(playersStepper.value), maximalWeek: Int(maxWeekStepper.value), startingInventory: Int(startInvStepper.value), backorderCost: backorderCostStepper.value, inventoryCost: invCostStepper.value)
        
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        BeergameAPI.newGame(userId, game: game) { (response) -> Void in            
            switch response.result {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                }
            case .Failure:
                // TODO: Error handling
                return
            }
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Keyboard related actions
    func dismissKeyboard() {
        view.endEditing(true)
    }
}