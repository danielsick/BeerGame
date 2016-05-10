import UIKit

class OrderViewController: UIViewController {
    
    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            fetchPlaysheetEntry()
        }
    }
    var playsheetEntry: PlaysheetEntry?
    
    private var defaultFrameY: CGFloat?
    
    // MARK: - Outlets
    @IBOutlet weak var labelIncomingOrder: UILabel!
    @IBOutlet weak var labelYourDelivery: UILabel!
    @IBOutlet weak var labelBackorder: UILabel!
    @IBOutlet weak var labelInventory: UILabel!
    @IBOutlet weak var textFieldOrder: UITextField!
    
    // MARK: - Actions
    @IBAction func orderButtonClicked(sender: UIButton) {
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        
        // Order text field is empty
        guard let orderValue = Int(textFieldOrder.text!) else {
            self.showAlert("Error", message: "Please enter an order value.", handler: nil)
            return
        }
        
        BeergameAPI.order((game!.gameId)!, userId: userId, order: orderValue) { (response) -> Void in
            switch response.result {
            case .Success:
                // 200 OK
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Success", message: "The order was successfully set.") { (UIAlertAction) -> Void in
                        // Switches to the home view controller after clicking ok
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    
                    // Disables the order tab
                    if let items = self.tabBarController!.tabBar.items {
                        items[1].enabled = false
                    }
                }
            case .Failure:
                // Error Handling
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Error", message: "The order could not be set.", handler: nil)
                }
            }
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if game == nil {
            game = (self.tabBarController as! PlayTabBarController).game
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultFrameY = self.view.frame.origin.y
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Keyboard related actions
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = defaultFrameY! - 50
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = defaultFrameY!
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    /**
     Loads playsheet entry values of the current week into the model.
    */
    private func fetchPlaysheetEntry() {
        let userId = PreferencesManager.loadValueForKey("userid") as! Int
        BeergameAPI.getPlaysheetValues(game!.gameId!,userId: userId) { (response) -> Void in
            switch response.result {
            case .Success(let playsheetEntry):
                // 200 OK
                self.playsheetEntry = playsheetEntry
                
                // Update UI
                dispatch_async(dispatch_get_main_queue()) {
                    self.labelIncomingOrder.text = "\((self.playsheetEntry?.incomingOrder)!)"
                    self.labelYourDelivery.text = "\((self.playsheetEntry?.outgoingDelivery)!)"
                    self.labelBackorder.text = "\((self.playsheetEntry?.backorder)!)"
                    self.labelInventory.text = "\((self.playsheetEntry?.inventory)!)"
                }
            case .Failure:
                // Error handling
                self.log("Playsheet values could not be fetched.")
            }
        }
    }
    
    /**
     Logs error message.
    */
    private func log(whatToLog: AnyObject) {
        debugPrint("OrderViewController: \(whatToLog)")
    }
}
