//
//  MessageTableViewCell.swift
//  DemoGPT
//
//  Created by Krish Patel on 3/24/24.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    static let reuseID = "MessageCell"
    
    let stackView = UIStackView()
    var userLabel = UILabel()
    var messageLabel = UILabel()
    
    let decorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setup and Layouts
extension MessageTableViewCell {
    
    private func setup() {
        // Content View
        contentView.backgroundColor = UIColor(red: 52/255, green: 58/255, blue: 64/255, alpha: 1)
        
        // StackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // DecorView
        decorView.translatesAutoresizingMaskIntoConstraints = false
        decorView.backgroundColor = .white
        
        // Labels
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        userLabel.numberOfLines = 1
        userLabel.textColor = .white
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
    }
    
    private func layout() {
        // Add Views to contentView
        contentView.addSubview(userLabel)
        contentView.addSubview(decorView)
        contentView.addSubview(messageLabel)
        
        // Layouts
        NSLayoutConstraint.activate([
            userLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            userLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            decorView.topAnchor.constraint(equalToSystemSpacingBelow: userLabel.bottomAnchor, multiplier: 0.5),
            decorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            decorView.trailingAnchor.constraint(equalToSystemSpacingAfter: userLabel.trailingAnchor, multiplier: 1),
            decorView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalToSystemSpacingBelow: decorView.bottomAnchor, multiplier: 1),
            messageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: messageLabel.trailingAnchor, multiplier: 2)
        ])
        
    }
}
