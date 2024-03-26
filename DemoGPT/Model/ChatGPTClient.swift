//
//  ChatGPTClient.swift
//  DemoGPT
//
//  Created by Krish Patel on 3/25/24.
//

import Foundation
import Alamofire

class ChatGPTClient {
    
    let baseURL = "https://api.openai.com/v1"
    let headers: HTTPHeaders = ["Authorization": "Bearer \(APIInfo.apiKey)"]
    
    func generateText(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "model": "text-davinci-002",
            "prompt": prompt,
            "temperature": 1,
            "max_tokens": 50
        ]
        
        AF.request(baseURL + "/engines/davinci-codex/completions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: ChatGPTResponse.self) { response in
                switch response.result {
                case .success(let chatGPTResponse):
                    completion(.success(chatGPTResponse.choices[0].text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

struct ChatGPTResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let text: String
    }
}
