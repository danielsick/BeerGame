import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: - Private Model
    private var defaultFrameY: CGFloat?
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Actions
    @IBAction func loginButtonPressed(sender: UIButton) {
        login()
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        register()
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        // Add little images to the left side of the textfields.
        let user = UIImageView(image: UIImage(named: "user.png"))
        let key = UIImageView(image: UIImage(named: "passwordIcon.png"))
        
        user.frame = CGRect(x: 0, y: 0, width: user.image!.size.width + 10.0, height: user.image!.size.height - 10.0)
        key.frame = CGRect(x: 0, y: 0, width: key.image!.size.width + 10.0, height: key.image!.size.height - 10.0)
        user.contentMode = .ScaleAspectFit
        key.contentMode = .ScaleAspectFit
        
        usernameTextField.leftView = user
        passwordTextField.leftView = key
        
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
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
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            login()
            return false
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    /**
     Performs the login with the login data in the textfields.
    */
    private func login() -> Void {
        // Get username and password from textfield.
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        // Prompt user if atleast one of the textfields is empty.
        if username == "" || password == "" {
            showEmptyUsernamePasswordAlert()
            return
        }
        
        // Perform login asynchronously.
        BeergameAPI.login(username, password: password) { (response) -> Void in
            switch response.result {
            case .Success(let user):
                // 200 OK
                // Mark user as logged in and segue to home screen.
                PreferencesManager.saveValue(user.name, key: "username")
                PreferencesManager.saveValue(user.userId, key: "userid")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("fromLogin", sender: self.loginButton)
                }
            case .Failure:
                // Error handling
                switch response.response?.statusCode {
                case 401?: self.showAlertAsync("Error", message: "Wrong password")
                case 404?: self.showAlertAsync("Error", message: "Wrong username")
                default: return
                }
            }
        }
    }
    
    /**
     Registers a new user with the data in the textfields.
     */
    private func register() -> Void {
        // Prompt user if atleast one of the textfields is empty.
        guard let username = usernameTextField.text, let password = passwordTextField.text
            where username != "" && password != "" else {
                showEmptyUsernamePasswordAlert()
                return
        }
        
        // Perform registration asynchronously
        BeergameAPI.register(username, password: password) { (response) -> Void in            
            switch response.result {
            case .Success(let user):
                // 200 OK
                // Notify the user that the registration was successful and set the textfields accordingly.
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Success", message: "Sign up successful. You can now login.")
                    self.usernameTextField.text = user.name
                    self.passwordTextField.text = user.password
                }
            case .Failure:
                // Error handling
                switch response.response?.statusCode {
                case 409?: self.showAlertAsync("Error", message: "A user with that name already exists.")
                case 500?: self.showAlertAsync("Error", message: "Internal server error")
                default: return
                }
            }
        }
    }
    
    /**
     Shows an alert which prompts the user to enter a username and password.
     */
    private func showEmptyUsernamePasswordAlert() {
        showAlert("Error", message: "Please enter Username and Password")
    }
}