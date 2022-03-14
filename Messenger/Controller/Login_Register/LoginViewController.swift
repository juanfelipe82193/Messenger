//
//  LoginViewController.swift
//  Messenger
//
//  Created by Juan Felipe Zorrilla Ocampo on 26/02/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // Create container UIScrollView to embed the logo, user, password and button for login
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    // image view to hold the logo
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0 ))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    // password field
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0 ))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    // login button
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    // Facebook login button
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    // Google login button
    private let googleLogInButton = GIDSignInButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonPressed),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        // Facebook subview
        scrollView.addSubview(fbLoginButton)
        // Google subview
        scrollView.addSubview(googleLogInButton)
        
        // Observe access token changes
        // This will trigger after successfully login / logout
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            
            // Print out access token
            print("FB Access Token: \(String(describing: AccessToken.current?.tokenString))")
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 4
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 120,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 20,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 20,
                                     width: scrollView.width - 60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 20,
                                   width: scrollView.width - 60,
                                   height: 52)
        fbLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom + 20,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        googleLogInButton.frame = CGRect(x: 30,
                                         y: fbLoginButton.bottom + 20,
                                         width: scrollView.width - 60,
                                         height: 52)
    }
    
    @objc private func loginButtonPressed() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.spinner.dismiss()
            }
            
            if let e = error {
                let errorString = e.localizedDescription
                let ac = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(action)
                self?.present(ac, animated: true, completion: nil)
            } else if let result = authResult {
                let user = result.user
                // Saving email to UserDefaults
                UserDefaults.standard.set(email, forKey: "email")
                
                print("Logged In User: \(user)")
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Whoops",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - UITextFieldDelegate methods

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonPressed()
        }
        
        return true
    }
    
}

//MARK: - FacebookLoginDelegate methods

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged out")
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        spinner.show(in: view)
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: AccessToken.current!.tokenString,
                                                         version: nil,
                                                         httpMethod: .get)
        facebookRequest.start { [unowned self] _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureURL = data["url"] as? String else {
                      print("Failed to get email and user name from Facebook results")
                      DispatchQueue.main.async {
                          self.spinner.dismiss()
                      }
                      return
                  }
            
            // Save email to UserDefaults
            UserDefaults.standard.set(email, forKey: "email")
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            guard let url = URL(string: pictureURL) else { return }
                            
                            print("Downloading data from Facebook Image")
                            
                            URLSession.shared.dataTask(with: url) { data, _, error in
                                guard let data = data else {
                                    print("Failed to get data from Facebook image")
                                    return
                                }
                                
                                print("Got data from Facebook, uploading...")
                                
                                // upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }.resume()
                        }
                    }
                    DispatchQueue.main.async {
                        self.spinner.dismiss()
                    }
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard authResult != nil, error == nil else {
                    print("Facebook credential login failed, MFA may be required")
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                print("Successfully logged user in")
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
