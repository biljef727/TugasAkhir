//
//  ApiManagerTeacher.swift
//  TA
//
//  Created by Billy Jefferson on 04/04/24.
//

import Foundation

class ApiManagerTeacher {
    func addNewExam(examName: String, section1: Int, section2: Int, section3: Int, file: Data?, userId: String, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "http://localhost:8000/api/addNewExam")!
        
        var requestBody : [String : Any] = [
            "ExamName": examName,
            "ExamSection1": section1,
            "ExamSection2": section2,
            "ExamSection3": section3,
            "UserID": userId
        ]
        
        if let fileData = file {
            // Convert file data to base64 string
            let fileBase64String = fileData.base64EncodedString()
            requestBody["ExamFile"] = fileBase64String
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
                completion(nil)
            }.resume()
        } catch {
            completion(error)
        }
    }
    func fetchClassID(userID: String, completion: @escaping(Result<([String], [String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/fetchExamData?UserID=\(userID)"
        
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
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examNames = decodedData["ExamName"], let examSectionCounter = decodedData["ExamCounter"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examNames, examSectionCounter)))
                } catch {
                    print("Error parsing JSON: \(error)")
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
    
    func fetchScheduleID(userID: String, completion: @escaping(Result<([String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/scheduleExamID?UserID=\(userID)"
        
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
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examID = decodedData["ExamID"]else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success(examID))
                } catch {
                    print("Error parsing JSON: \(error)")
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
    
    func fetchClassTeacher(userID: String, completion: @escaping(Result<([String],[String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/teacherClassID?UserID=\(userID)"
        
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
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let teacherClassID = decodedData["TeacherClass"],let classID = decodedData["TeacherID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((teacherClassID,classID)))
                } catch {
                    print("Error parsing JSON: \(error)")
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
    
    func addNewScheduleExam(examID: String, classID: String, examDate: Double, startExamTime: Double, endExamTime: Double, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "http://localhost:8000/api/addScheduleExam")!
//        let _ = print("1")
        var requestBody : [String : Any] = [
            "ExamID": examID,
            "ClassID": classID,
            "ExamDate": examDate,
            "StartExamTime": startExamTime,
            "EndExamTime": endExamTime
        ]
//        let _ = print("2")
//        let _ = print(requestBody)
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let _ = print("3")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
//            let _ = print("4")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
//                let _ = print("5")
                if let error = error {
//                    let _ = print("6")
                    completion(error)
                    return
                }
//                let _ = print("7")
                completion(nil)
            }.resume()
        } catch {
//            let _ = print("8")
            completion(error)
        }
    }
    
    func getScheduleExamName(userID:String, completion: @escaping (Result<(examNames: [String], examDates: [String],startExamTimes: [String], endExamTimes: [String], classNames:[String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/scheduleExamData?UserID=\(userID)"
        
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
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examNames = decodedData["ExamName"], let examDates = decodedData["ExamDate"],let startExamTimes = decodedData["StartExamTime"], let endExamTimes = decodedData["EndExamTime"],let classNames = decodedData["ClassName"]else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examNames, examDates,startExamTimes,endExamTimes,classNames)))
                } catch {
                    print("Error parsing JSON: \(error)")
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
    func fetchClassIDandNames(userID: String, completion: @escaping(Result<([String], [String]), Error>) -> Void) {
        let urlString = "http://localhost:8000/api/getClassIDandNames?UserID=\(userID)"
        
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
                do {
                    let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
                    guard let examNames = decodedData["ExamName"], let examID = decodedData["ExamID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examNames, examID)))
                } catch {
                    print("Error parsing JSON: \(error)")
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

