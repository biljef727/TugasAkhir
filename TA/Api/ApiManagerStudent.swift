//
//  ApiManagerStudent.swift
//  TA
//
//  Created by Billy Jefferson on 08/04/24.
//

import Foundation
class ApiManagerStudent {
    func fetchPDF(userID: String, examID: String, completion: @escaping (Result<String, Error>) -> Void) {
            // Construct the URL string with userID and examID parameters
            let urlString = "https://indramaryati.xyz/iph_exam/public/api/getFile?UserID=\(userID)&ExamID=\(examID)"
            
            // Validate the URL
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            // Create the URLRequest object
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Perform the network request
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Check for errors
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // Ensure there is data in the response
                guard let data = data else {
                    let errorMessage = "No data received from server"
                    print("Error: \(errorMessage)")
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                // Validate the HTTP response
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    do {
                        // Decode the JSON response
                        let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                        // Extract the "FileName" value
                        if let examFile = decodedData["FileName"] {
                            completion(.success(examFile))
                        } else {
                            let errorMessage = "Invalid response format: 'FileName' key not found"
                            print("Error: \(errorMessage)")
                            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else {
                    // Handle invalid HTTP response status codes
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let errorMessage = "Server returned status code \(statusCode)"
                    print("Error: \(errorMessage)")
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }.resume()  // Start the network request
        }
    func fetchExamNow(userID: String, completion: @escaping(Result<([String],[String],[String],[String],[String]), Error>) -> Void) {
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
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard
                        let startDateTime = decodedData["startDateTime"],
                        let startExamTimes = decodedData["startExamTime"],
                        let endExamTimes = decodedData["endExamTime"],
                        let examNames = decodedData["examName"],
                        let examIDs = decodedData["examID"]
                    else {
                        //                        let _ = print("8")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    //                    let _ = print(startExamTimes)
                    //                    let _ = print(endExamTimes)
                    completion(.success((startDateTime,startExamTimes,endExamTimes,examNames,examIDs)))
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
    func fetchExamWas(userID: String, completion: @escaping(Result<([String],[String],[String],[String],[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/examWas?UserID=\(userID)"
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
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard
                        let startDateTime = decodedData["startDateTime"],
                        let startExamTimes = decodedData["startExamTime"],
                        let endExamTimes = decodedData["endExamTime"],
                        let examNames = decodedData["examName"],
                        let examIDs = decodedData["examID"]
                    else {
                        //                        let _ = print("8")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    //                    let _ = print(startExamTimes)
                    //                    let _ = print(endExamTimes)
                    completion(.success((startDateTime,startExamTimes,endExamTimes,examNames,examIDs)))
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
    func addKerjaan(examID: String, section1: String, section2: String, section3: String, file: Data?, userId: String, status: String, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/insertKerjaan")!
        
        var requestBody: [String: Any] = [
            "ExamID": examID,
            "NilaiSection1": section1,
            "NilaiSection2": section2,
            "NilaiSection3": section3,
            "UserID": userId,
            "StatusScore": status
        ]
        
        // Add file data if available
        if let fileData = file {
            requestBody["NilaiFile"] = fileData.base64EncodedString()
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                let statusCode = httpResponse.statusCode
                if (200..<300).contains(statusCode) {
                    // Success response
                    completion(nil)
                } else {
                    // Non-success response
                    let responseString = String(data: data ?? Data(), encoding: .utf8)
                    let error = NSError(domain: "", code: statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Server returned status code \(statusCode)",
                        NSLocalizedFailureReasonErrorKey: "Response: \(responseString ?? "")"
                    ])
                    completion(error)
                }
            }.resume()
        } catch {
            completion(error)
        }
    }
    func fetchScore(userID: String,examID:String, completion: @escaping(Result<(String,String,String,String,String,String,String,String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/getNilai?UserID=\(userID)&ExamID=\(examID)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let _ = print("4")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                let _ = print("5")
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            let _ = print("6")
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                do {
                    let decodedData = try JSONDecoder().decode([String: String?].self, from: data)
                    guard
                        let studentName = decodedData["studentName"] ?? nil,
                        let examName = decodedData["examName"] ?? nil,
                        let score1 = decodedData["score1"] ?? nil,
                        let score2 = decodedData["score2"] ?? nil,
                        let score3 = decodedData["score3"] ?? nil,
                        let totalScore = decodedData["totalScore"] ?? nil,
                        let nilaiTambahan = decodedData["nilaiTambahan"] ?? nil,
                        let statusScore = decodedData["statusScore"] ?? nil
                    else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((studentName, examName, score1, score2, score3, totalScore, nilaiTambahan, statusScore)))
                } catch {
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

