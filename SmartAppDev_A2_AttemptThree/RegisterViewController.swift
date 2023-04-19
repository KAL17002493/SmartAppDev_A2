//
//  RegisterViewController.swift
//  APIexercise
//
//  Created by Richard Kalnarajs (Student) on 22/03/2023.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var notification: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //Password Validation
    //    length 6 to 16.
    //    One Alphabet in Password.
    //    One Special Character in Password.
    func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,16}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        let result = passwordTest.evaluate(with: password)
        return result
    }
    
    //NOT IMPLEMENTED YET
    //Validate email address logic
    func isValidEmail(email: String) -> Bool {
        //Declaring the rule of characters to be used. Applying rule to current state. Verifying the result.
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        return result
    }
    
    //NOT IMPLEMENTED YET
    //validate name logic
    func isValidName(username: String) -> Bool {
        //Declaring the rule of characters to be used. Applying rule to current state. Verifying the result.
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: username)
        return result
    }
    
    
    @IBAction func registerButton(_ sender: Any)
    {
        guard let username = username.text,
              let password = password.text,
              let email = email.text else {
            return
        }
         
        //Outputs error if password is not valid
        if(isValidPassword(password: password) == false)
        {
            self.notification.text = "Password must contain between 6 - 16 characters, One aplhabet character and one special character"
        }
        //Outputs error if email is not valid
        if(isValidEmail(email: email) == false)
        {
            self.notification.text = "Email must contain an @ and . symbol"
        }
        //Outputs error iv username is not valid
        if(isValidName(username: username) == false)
        {
            self.notification.text = "Username can only contain alphabet character and must have 2+ characters"
        }
        
        //If all checks valid user registered
        if(isValidPassword(password: password) == true && isValidEmail(email: email) == true && isValidName(username: username) == true)
        {
            
            let parameters = ["username": username, "password": password, "email": email]
            
            guard let url = URL(string: "http://127.0.0.1:5000/api/users/register") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    print("Error: Invalid response")
                    return
                }
                
                guard let data = data else {
                    print("Error: No data received")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String: Any],
                       let registerSuccess = dict["Register_Success"] as? Bool,
                       registerSuccess == true {
                        print("User registration successful")
                        DispatchQueue.main.async {
                            self.notification.text = "Registraion has been successful"
                            
                            let LoginVC = (self.storyboard?.instantiateViewController (withIdentifier:"LoginVC"))!
                            self.navigationController?.pushViewController(LoginVC, animated: true)
                        }
                    } else {
                        print("User registration failed")
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }.resume()
        }
    }}
