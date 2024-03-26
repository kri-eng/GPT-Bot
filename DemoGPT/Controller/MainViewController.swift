//
//  MainViewController.swift
//  DemoGPT
//
//  Created by Krish Patel on 3/24/24.
//

import UIKit
import OpenAISwift

class MainViewController: UIViewController {

    let tableView = UITableView()
    let horizontalStackView = UIStackView()
    let inputTextField = UITextField()
    let sendButton = UIButton()
    
    let openAI = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: APIInfo.apiKey))
    var messages: [Message] = []
    var messagesQuery: [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Delegates and Datasources
        tableView.delegate = self
        tableView.dataSource = self
        inputTextField.delegate = self
        
        // Register cell Layouts
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.reuseID)
        
        setup()
        layout()
    }
}

// MARK: - Setup and Layout
extension MainViewController {
    
    private func setup() {
        // TableView.
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 52/255, green: 58/255, blue: 64/255, alpha: 1)
        tableView.rowHeight = 100
        
        // Input Text Field
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.returnKeyType = .default
        inputTextField.placeholder = "Enter Query."
        inputTextField.backgroundColor = .white
        inputTextField.layer.cornerRadius = 10
        inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        inputTextField.leftViewMode = .always
        inputTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        inputTextField.rightViewMode = .always
        
        // Send Button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "paperplane.circle.fill"), for: .normal)
        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        sendButton.tintColor = .white
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        
        // StackView
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
    }
    
    private func layout() {
        // Adding views and subviewsa
        horizontalStackView.addArrangedSubview(inputTextField)
        horizontalStackView.addArrangedSubview(sendButton)
        view.addSubview(tableView)
        view.addSubview(horizontalStackView)
            
        // Handle Layouts
        NSLayoutConstraint.activate([
            
            // TableView Layouts
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 0),
            tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 0),
            
            // StackView Layouts
            horizontalStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: horizontalStackView.trailingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: horizontalStackView.bottomAnchor, multiplier: 2),
            
            // InputTextField
            inputTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Send Button
            sendButton.widthAnchor.constraint(equalToConstant: 48),
            sendButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseID, for: indexPath) as! MessageTableViewCell
        
        if messages[indexPath.row].isUser {
            cell.userLabel.text = "User"
        } else {
            cell.userLabel.text = "AI Bot"
        }
        
        cell.messageLabel.text = messages[indexPath.row].messageText
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = messages[indexPath.row].messageText
        let font = UIFont.preferredFont(forTextStyle: .subheadline) // Use the appropriate font
        let labelWidth = tableView.frame.width - 16 // Adjust for any insets or margins

        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        let labelSize = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))

        // Add any additional padding or margins as needed
        return labelSize.height + 40 // Adjust this value as needed
    }
}

//MARK: - Button Actions
extension MainViewController {
    
    @objc func sendPressed(_ sender: UIButton) {
        let query = inputTextField.text ?? ""
//        print("User: \(query)")
        
        if query != "" {
            messages.append(Message(isUser: true, messageText: query))
            searchOpenAI(with: query)
        }
        
        // Clear the text in text field
        inputTextField.text = ""
        tableView.reloadData()
    }
}


//MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("User: \(textField.text ?? "No value")")
    }
}

//MARK: - Search OpenAI
extension MainViewController {
    
    private func searchOpenAI(with query: String) {
        populateMessageQuery()
        generateText(with: query)
    }
    
    private func populateMessageQuery() {
        for message in messages {
            var role = "assistant"
            if message.isUser {
                role = "user"
            }

            let formattedMessage = [
                "role": role,
                "content": message.messageText
            ]
            messagesQuery.append(formattedMessage)
        }
    }
}

//MARK: - Generate Text
extension MainViewController {
    
    private func generateText(with prompt: String) {
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(APIInfo.apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let parameters: [String: Any] = [
                "messages": messagesQuery,
                "model" : "gpt-3.5-turbo-0125",
                "max_tokens": 100,
                "temperature": 0.7,
                "frequency_penalty": 0.5,
                "presence_penalty": 0.5,
                "stop": ["\n"]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }

                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let choice = choices.first,
                       let message = choice["message"] as? [String: String],
                       let content = message["content"] {
                        let newMessage = Message(isUser: false, messageText: content)
                        DispatchQueue.main.async {
                            self.messages.append(newMessage)
                            self.tableView.reloadData()
                        }
                        // You can also print the content if needed
                        //print(content)
                    }
                }
                
//                if let dataString = String(data: data, encoding: .utf8) {
//                    print("Received data as string:\n\(dataString)")
//                } else {
//                    print("Failed to decode data as UTF-8 string")
//                }
                
            }

            task.resume()
        }
}
