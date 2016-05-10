import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Model
    var defaultFrameY: CGFloat?
    
    // MARK: - Outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func okClicked(sender: UIButton) {
        changePassword()
    }
    
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if textField == confirmPasswordTextField {
            confirmPasswordTextField.resignFirstResponder()
            changePassword()
            return false
        }
        return true
    }
    
    // MARK: - Private Methods
    /**
     Changes the password of the user with the data provided by the textfields.
    */
    private func changePassword() {
        if let currentPassword = currentPasswordTextField.text,
            let newPassword = newPasswordTextField.text,
            let confirmPassword = confirmPasswordTextField.text {
                if newPassword == confirmPassword {
                    let userId = PreferencesManager.loadValueForKey("userid") as! Int
                    BeergameAPI.changePassword(userId, oldPassword: currentPassword, newPassword: newPassword) { (response) -> Void in
                        switch response.result {
                        case .Success:
                            dispatch_async(dispatch_get_main_queue()) {
                                self.showAlert("Success", message: "Your password was changed successfully") { (UIAlertAction) -> Void in
                                    self.performSegueWithIdentifier("logout", sender: self)
                                }
                            }
                        case .Failure:
                            switch response.response?.statusCode {
                            case 404?: self.showAlertAsync("Error", message: "The user does not exist.")
                            case 401?: self.showAlertAsync("Error", message: "The entered old password is wrong.")
                            case 400?: self.showAlertAsync("Error", message: "The new password equals the old password.")
                            default: self.showAlertAsync("Error", message: "An error occurred while updating your password.")
                            }
                        }
                    }
                }
        }
    }
}