//
//  Message.swift
//  DemoGPT
//
//  Created by Krish Patel on 3/24/24.
//

import Foundation

struct Message {
    
    let isUser: Bool
    let messageText: String
    
    init(isUser: Bool, messageText: String) {
        self.isUser = isUser
        self.messageText = messageText
    }
}

