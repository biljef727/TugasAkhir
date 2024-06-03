//
//  ApiManagerTeacher.swift
//  TA
//
//  Created by Billy Jefferson on 04/04/24.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

class ApiManagerTeacher {
    func addNewExam(examName: String, section1: Int, section2: Int, section3: Int, file: Data?, userId: String, documentName: String, completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/addNewExam")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add examName
        let examName = "\(examName)\r\n" // Convert string
//        if let examNameData = examName.data(using: .utf8) {
//            let _ = print(examNameData)
//           /* body.append(examNameData)*/ // Append the converted data
//        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"examName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(examName)\r\n".data(using: .utf8)!)

        // Add section1
        let section1String = "\(section1)\r\n" // Convert int to string
//        if let section1Data = section1String.data(using: .utf8) {
//            let _ = print(section1Data)
//            body.append(section1Data) // Append the converted data
//        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"section1\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(section1)\r\n".data(using: .utf8)!)
        
        // Add section2
        let section2String = "\(section2)\r\n" // Convert int to string
//        if let section2Data = section2String.data(using: .utf8) {
//            let _ = print(section2Data)
//            body.append(section2Data) // Append the converted data
//        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"section2\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(section2)\r\n".data(using: .utf8)!)
        
        // Add section3
        let section3String = "\(section3)\r\n" // Convert int to string
//        if let section3Data = section3String.data(using: .utf8) {
//            let _ = print(section3Data)
//            body.append(section3Data) // Append the converted data
//        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"section3\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(section3)\r\n".data(using: .utf8)!)
        
        // Update the parameter name for UserID
        let userid = "\(userId)\r\n" // Corrected parameter name
//        if let userData = userid.data(using: .utf8) {
//            let _ = print(userData)
//            body.append(userData) // Append the converted data
//        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        
        // Add file if available
        if let fileData = file {
            let filename = documentName.isEmpty ? "examFile.pdf" : documentName
            let mimetype = "application/pdf"
            
//            let _ = print(filename)
            // Append file data
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"ExamFile\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
//            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!) // Correct boundary formatting
        }

        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
                return
            }
            // Handle server response if necessary
            
            completion(nil)
        }.resume()
    }
    
    func fetchClassID(userID: String, completion: @escaping(Result<([String], [String],[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/fetchExamData?UserID=\(userID)"
        
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
                    guard let examNames = decodedData["ExamName"], 
                            let examSectionCounter = decodedData["ExamCounter"],
                    let examFile = decodedData["ExamFile"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examNames, examSectionCounter,examFile)))
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
    func fetchExamCounter(examID: String, completion: @escaping(Result<(String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/fetchExamCounter?ExamID=\(examID)"
        
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
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    guard let examCounter = decodedData["ExamCounter"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success(examCounter))
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
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/scheduleExamID?UserID=\(userID)"
        
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
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/teacherClassID?UserID=\(userID)"
        
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
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/addScheduleExam")!
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
    
    func getScheduleExamName(userID:String, completion: @escaping (Result<(examIDs:[String],examNames: [String], examDates: [String],startExamTimes: [String], endExamTimes: [String], classNames:[String],classID:[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/scheduleExamData?UserID=\(userID)"
        
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
                    guard let examIDs = decodedData["ExamID"],let examNames = decodedData["ExamName"], let examDates = decodedData["ExamDate"],let startExamTimes = decodedData["StartExamTime"], let endExamTimes = decodedData["EndExamTime"],let classNames = decodedData["ClassName"], let classID = decodedData["ClassID"] else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((examIDs,examNames, examDates,startExamTimes,endExamTimes,classNames,classID)))
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
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/getClassIDandNames?UserID=\(userID)"
        
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
    
    func fetchStudentIDandNames(classID: String, examID: String, completion: @escaping(Result<([String], [String],[String],[String],[String]), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/studentExamResult?ClassID=\(classID)&ExamID=\(examID)"
        
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
                    guard let studentNames = decodedData["studentName"], let studentID = decodedData["studentID"],let nilaiTotal = decodedData["nilaiTotal"],let statusScore = decodedData["statusScore"], let nilaiFile = decodedData["nilaiFile"]else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    completion(.success((studentNames, studentID,nilaiTotal,statusScore,nilaiFile)))
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
    
    func fetchNilaiStudent(userID: String, completion: @escaping(Result<(String,String,String,String), Error>) -> Void) {
        let urlString = "https://indramaryati.xyz/iph_exam/public/api/requestDataEdit?UserID=\(userID)"
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
                    guard let studentName = decodedData["studentName"],
                          let studentID = decodedData["studentID"],
                          let examName = decodedData["examName"],
                          let examCounter = decodedData["examCounter"]
                    else {
                        //                        let _ = print("8")
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    //                    let _ = print("9")
                    completion(.success((studentName, studentID, examName, examCounter)))
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
    
    func editStatusScore(userID: String,examID:String, NilaiSection1: Int, NilaiSection2: Int, NilaiSection3: Int,NilaiTotal:Int,feedback:String,completion: @escaping (Error?) -> Void) {
        let apiUrl = URL(string: "https://indramaryati.xyz/iph_exam/public/api/editStatusScore")!
                        let _ = print("1")
        var requestBody : [String : Any] = [
            "UserID": userID,
            "ExamID":examID,
            "NilaiSection1": NilaiSection1,
            "NilaiSection2": NilaiSection2,
            "NilaiSection3": NilaiSection3,
            "NilaiTotal": NilaiTotal,
            "NilaiCatTambahan" : feedback
        ]
        let _ = print(userID)
        let _ = print(NilaiSection1)
        let _ = print(NilaiSection2)
        let _ = print(NilaiSection3)
        let _ = print(NilaiTotal)
        let _ = print(feedback)
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let _ = print("3")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            let _ = print("4")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                let _ = print("5")
                if let error = error {
                    let _ = print("6")
                    completion(error)
                    return
                }
                let _ = print("7")
                completion(nil)
            }.resume()
        } catch {
            let _ = print("8")
            completion(error)
        }
    }
}

