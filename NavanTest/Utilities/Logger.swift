//
//  Logger.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation

struct Logger {
    static func logRequest(_ request: URLRequest) {
        guard let url = request.url else { return }
        print("📤 Request: \(request.httpMethod ?? "UNKNOWN") \(url.absoluteString)")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
    
    static func logResponse(_ response: URLResponse, data: Data) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        print("📥 Response: \(httpResponse.statusCode) \(response.url?.absoluteString ?? "UNKNOWN")")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }
    }
}
