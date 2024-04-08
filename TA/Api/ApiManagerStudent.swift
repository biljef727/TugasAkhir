//
//  ApiManagerStudent.swift
//  TA
//
//  Created by Billy Jefferson on 08/04/24.
//

import Foundation

func fetchPDF(classID: String, completion: @escaping (Result<String, Error>) -> Void) {
    let urlString = "http://localhost:8000/api/getFile?ClassID=\(classID)"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            completion(.failure(error!))
            return
        }
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            if let pdfBase64String = String(data: data, encoding: .utf8) {
                completion(.success(pdfBase64String))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode PDF Base64 string."])))
            }
        } else {
            if let errorMessage = String(data: data, encoding: .utf8) {
                // Handle error message
            } else {
                // Handle unknown error
            }
        }
    }.resume()
}

