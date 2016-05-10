import UIKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Model
    var defaultFrameY: CGFloat?
    
    // MARK: - Outlets
    @IBOutlet weak var currentNameLabel: UILabel!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func okClicked(sender: UIButton) {
        changeUsername()
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentNameLabel.text = "Current name: \(PreferencesManager.loadValueForKey("username") as! String)"
        
        defaultFrameY = self.view.frame.origin.y
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "logout":
                PreferencesManager.deleteValueForKey("username")
                PreferencesManager.deleteValueForKey("userid")
            default:
                break
            }
        }
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
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            changeUsername()
            return false
        }
        return true
    }
    
    // MARK: - Private Methods
    /**
     Changes the username of a user with the data provided by the textfields.
    */
    private func changeUsername() {
        if let newName = newNameTextField.text, let pass = passwordTextField.text {
            let userId = PreferencesManager.loadValueForKey("userid") as! Int
            BeergameAPI.changeUsername(userId, newName: newName, password: pass) { (response) -> Void in
                switch response.result {
                case .Success:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlert("Success", message: "Your name was changed successfully") { (UIAlertAction) -> Void in
                            self.performSegueWithIdentifier("logout", sender: self)
                        }
                    }
                case .Failure:
                    switch response.response?.statusCode {
                    case 404?: self.showAlertAsync("Error", message: "The user does not exist")
                    case 400?: self.showAlertAsync("Error", message: "The new username euals the old username")
                    case 409?: self.showAlertAsync("Error", message: "The entered username is already taken")
                    case 401?: self.showAlertAsync("Error", message: "The entered password is wrong")
                    default: self.showAlertAsync("Error", message: "An error occurred while updating your name")
                    }
                }
            }
        }
    }
}