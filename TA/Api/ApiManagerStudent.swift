//
//  ApiManagerStudent.swift
//  TA
//
//  Created by Billy Jefferson on 08/04/24.
//

import Foundation
class ApiManagerStudent {
    func fetchPDF(userID: String, examID: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/getFile?UserID=\(userID)&ExamID=\(examID)"
        
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
                if let decodedData = Data(base64Encoded: data) {
                    completion(.success(decodedData))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode Base64 string."])))
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

    func fetchExamNow(userID: String, completion: @escaping(Result<(String,String,String,String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/examNow?UserID=\(userID)"
//        let _ = print("1")
        guard let url = URL(string: urlString) else {
//            let _ = print("2")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
//        let _ = print("3")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let _ = print("4")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
//                let _ = print("5")
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
//            let _ = print("6")
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
//                    let _ = print("7")
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    guard let startExamTimes = decodedData["startExamTime"],
                          let endExamTimes = decodedData["endExamTime"],
                          let examNames = decodedData["examName"],
                          let examIDs = decodedData["examID"]
                    else {
//                        let _ = print("8")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    let _ = print(startExamTimes)
                    let _ = print(endExamTimes)
                    completion(.success((startExamTimes,endExamTimes,examNames,examIDs)))
                } catch {
//                    let _ = print("10")
                    completion(.failure(error))
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
}

