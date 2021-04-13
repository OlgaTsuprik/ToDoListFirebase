//
//  ViewController.swift
//  ToDoListFirebase
//
//  Created by Оля on 08.04.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Properties
    let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    
    // MARK: Outlets
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    // MARK: Life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "users")
        
        self.keyboardHideWhenTappedAround()
        warningLabel.alpha = 0
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: self?.segueIdentifier ?? "", sender: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeybordNotifications()
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterForKeybordNotifications()
    }
    
    // MARK: Methods
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = (notification as Notification).userInfo else { return }
        guard let keyboardNSValue: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        var keyboardFrame: CGRect = keyboardNSValue.cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, to: nil)
        //self.mainScrollView.contentInset.bottom = keyboardFrame.size.height
        (self.view as! UIScrollView).contentInset.bottom = keyboardFrame.size.height
    }
    
    @objc private func keyboardWillHide() {
        (self.view as! UIScrollView).contentInset.bottom = .zero
    }
    
    func keyboardHideWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func displayWarningLabel(withText text: String) {
        warningLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.warningLabel.alpha = 1
        } completion: { [weak self] (complete) in
            self?.warningLabel.alpha = 0
        }
    }
    
    // MARK: Observers
    private func registerForKeybordNotifications() {
        self.unregisterForKeybordNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)    }
    
    private func unregisterForKeybordNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // MARK: IB Action
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: self?.segueIdentifier ?? "", sender: nil)
                return
            }
            self?.displayWarningLabel(withText: "No such user")
        }
        
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (authResult, error) in
            guard error == nil, authResult != nil else {
                print(error?.localizedDescription)
                return
            }
            let userRef = self?.ref.childByAutoId()
            userRef?.setValue(["email": email])
            //ref.updateChildValues(childUpdates)
            
        })
    }
}
